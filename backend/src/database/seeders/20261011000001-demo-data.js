const bcrypt = require('bcryptjs');
const slugify = require('../../utils/slugify');
const { addDays, todayWib, toDateTime, generateSlots } = require('../../utils/time');
const { sequelize, User, Category, Service, Schedule, Booking, Payment, BookingStatusLog } = require('../../models');

const DAYS_BACK = 7;
const DAYS_AHEAD = 14;

const categories = ['Site Survey', 'Cage Installation', 'Maintenance & Repair', 'Flock Health', 'Consultation'];

// capacity = field teams available per slot; slots run 09:00-17:00, so duration sets the slot count
const services = [
  { category: 'Site Survey', name: 'Coop Site Survey', imageUrl: '/service-images/coop-site-survey.svg', price: 150000, durationMinutes: 120, capacity: 2, description: 'Visit the farm, measure the land and plan the layer coop layout.' },
  { category: 'Cage Installation', name: 'Battery Cage Installation (500 birds)', imageUrl: '/service-images/battery-cage-500.svg', price: 1500000, durationMinutes: 240, capacity: 1, description: 'Assemble and install battery cages for up to 500 laying hens.' },
  { category: 'Cage Installation', name: 'Battery Cage Installation (1,000 birds)', imageUrl: '/service-images/battery-cage-1000.svg', price: 2750000, durationMinutes: 480, capacity: 1, description: 'Full-day installation of battery cages for up to 1,000 laying hens.' },
  { category: 'Maintenance & Repair', name: 'Cage Repair & Maintenance', imageUrl: '/service-images/cage-repair.svg', price: 250000, durationMinutes: 120, capacity: 2, description: 'Fix bent wire, egg trays and doors, then check every cage row.' },
  { category: 'Maintenance & Repair', name: 'Nipple Drinker System Setup', imageUrl: '/service-images/nipple-drinker.svg', price: 350000, durationMinutes: 120, capacity: 2, description: 'Install or replace nipple drinker lines and the water regulator.' },
  { category: 'Flock Health', name: 'Layer Vaccination Visit', imageUrl: '/service-images/layer-vaccination.svg', price: 200000, durationMinutes: 90, capacity: 2, description: 'On-farm vaccination for laying hens by a poultry health officer.' },
  { category: 'Consultation', name: 'Layer Farm Consultation', imageUrl: '/service-images/layer-consultation.svg', price: 100000, durationMinutes: 60, capacity: 3, description: 'One on one advice on feed, lighting and egg production.' },
  // Appended last so existing service ids stay the same; pos-pro links its cages to this one by id
  { category: 'Cage Installation', name: 'Battery Cage Installation (up to 50 birds)', imageUrl: '/service-images/battery-cage-50.svg', price: 250000, durationMinutes: 120, capacity: 2, description: 'Assemble and install a small set of battery cages for up to 50 laying hens.' },
];

// [customerIndex, serviceIndex, dayOffset, slotIndex, finalStatus]
const sampleBookings = [
  [0, 0, -6, 0, 'COMPLETED'],
  [1, 6, -6, 2, 'COMPLETED'],
  [1, 0, -5, 1, 'COMPLETED'],
  [0, 1, -4, 0, 'COMPLETED'],
  [1, 2, -3, 0, 'COMPLETED'],
  [0, 5, -3, 1, 'CANCELLED'],
  [0, 3, -2, 2, 'COMPLETED'],
  [1, 5, -1, 0, 'COMPLETED'],
  [0, 4, 1, 1, 'CONFIRMED'],
  [1, 6, 2, 3, 'PENDING'],
  [0, 0, 3, 0, 'PENDING'],
  [1, 3, 4, 1, 'CONFIRMED'],
  [0, 6, 5, 4, 'PENDING'],
];

const TABLES = 'booking_status_logs, payments, bookings, schedules, services, categories, refresh_tokens, users';

const resetTables = () => sequelize.query(`TRUNCATE ${TABLES} RESTART IDENTITY CASCADE`);

// Fixed ids so pos-pro demo data can refer to the same accounts
const DEMO_USER_IDS = {
  admin: '0a000000-0000-4000-8000-000000000001',
  budi: '0a000000-0000-4000-8000-000000000002',
  siti: '0a000000-0000-4000-8000-000000000003',
};

const seedUsers = async () => {
  const [adminHash, userHash] = await Promise.all([bcrypt.hash('Admin12345', 10), bcrypt.hash('User12345', 10)]);

  const admin = await User.create({
    id: DEMO_USER_IDS.admin,
    name: 'Admin Booking',
    email: 'admin@booking.com',
    phone: '081100000001',
    passwordHash: adminHash,
    role: 'ADMIN',
  });
  const customers = await User.bulkCreate(
    [
      { id: DEMO_USER_IDS.budi, name: 'Budi Santoso', email: 'budi@example.com', phone: '081234567890' },
      { id: DEMO_USER_IDS.siti, name: 'Siti Rahma', email: 'siti@example.com', phone: '081298765432' },
    ].map((data) => ({ ...data, passwordHash: userHash })),
  );
  return { admin, customers };
};

const seedCatalog = async () => {
  const createdCategories = await Category.bulkCreate(categories.map((name) => ({ name, slug: slugify(name) })));
  const categoryByName = Object.fromEntries(createdCategories.map((category) => [category.name, category]));

  const createdServices = [];
  for (const { category, capacity, ...data } of services) {
    const service = await Service.create({ ...data, categoryId: categoryByName[category].id });
    createdServices.push({ service, capacity });
  }
  return createdServices;
};

const seedSchedules = async (createdServices) => {
  const today = todayWib();
  for (const { service, capacity } of createdServices) {
    const slots = generateSlots('09:00', '17:00', service.durationMinutes);
    const rows = [];
    for (let offset = -DAYS_BACK; offset <= DAYS_AHEAD; offset += 1) {
      const date = addDays(today, offset);
      slots.forEach((slot) => rows.push({ serviceId: service.id, date, ...slot, capacity }));
    }
    await Schedule.bulkCreate(rows);
  }
};

const buildLogs = (status, customerId, adminId) => {
  const logs = [{ fromStatus: null, toStatus: 'PENDING', changedById: customerId, note: 'Booking created' }];
  if (status === 'CONFIRMED' || status === 'COMPLETED') logs.push({ fromStatus: 'PENDING', toStatus: 'CONFIRMED', changedById: adminId });
  if (status === 'COMPLETED') logs.push({ fromStatus: 'CONFIRMED', toStatus: 'COMPLETED', changedById: adminId });
  if (status === 'CANCELLED') logs.push({ fromStatus: 'PENDING', toStatus: 'CANCELLED', changedById: customerId, note: 'Cancelled by customer' });
  return logs;
};

const seedBookings = async ({ admin, customers }, createdServices) => {
  const today = todayWib();

  for (const [index, [customerIndex, serviceIndex, dayOffset, slotIndex, status]] of sampleBookings.entries()) {
    const customer = customers[customerIndex];
    const { service } = createdServices[serviceIndex];
    const date = addDays(today, dayOffset);
    const slots = await Schedule.findAll({ where: { serviceId: service.id, date }, order: [['startTime', 'ASC']] });
    const slot = slots[slotIndex];
    const slotStart = toDateTime(date, slot.startTime);
    const isPaid = status === 'COMPLETED' || status === 'CONFIRMED';

    const booking = await Booking.create(
      {
        bookingCode: `BK-SEED-${String(index + 1).padStart(4, '0')}`,
        userId: customer.id,
        serviceId: service.id,
        scheduleId: slot.id,
        totalPrice: service.price,
        status,
        payment: {
          amount: service.price,
          status: isPaid ? 'PAID' : 'UNPAID',
          method: isPaid ? 'TRANSFER' : null,
          paidAt: isPaid ? new Date(Math.min(slotStart.getTime(), Date.now())) : null,
        },
        logs: buildLogs(status, customer.id, admin.id),
      },
      { include: [{ model: Payment, as: 'payment' }, { model: BookingStatusLog, as: 'logs' }] },
    );

    // Backdate creation to one day before the slot so reports look realistic
    await sequelize.query('UPDATE bookings SET created_at = :createdAt WHERE id = :id', {
      replacements: { createdAt: new Date(slotStart.getTime() - 24 * 60 * 60 * 1000), id: booking.id },
    });

    if (status !== 'CANCELLED') {
      const bookedCount = slot.bookedCount + 1;
      await slot.update({ bookedCount, status: bookedCount >= slot.capacity ? 'FULL' : 'AVAILABLE' });
    }
  }
};

module.exports = {
  async up() {
    if (process.env.NODE_ENV === 'production') throw new Error('Seeding is disabled in production');

    await resetTables();
    const users = await seedUsers();
    const createdServices = await seedCatalog();
    await seedSchedules(createdServices);
    await seedBookings(users, createdServices);
    await sequelize.close();

    console.log('Admin    : admin@booking.com / Admin12345');
    console.log('Customer : budi@example.com / User12345');
    console.log('Customer : siti@example.com / User12345');
  },

  async down() {
    await resetTables();
    await sequelize.close();
  },
};
