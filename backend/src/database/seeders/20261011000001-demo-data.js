const bcrypt = require('bcryptjs');
const slugify = require('../../utils/slugify');
const { addDays, todayWib, toDateTime, generateSlots } = require('../../utils/time');
const { sequelize, User, Category, Service, Schedule, Booking, Payment, BookingStatusLog } = require('../../models');

const DAYS_BACK = 7;
const DAYS_AHEAD = 14;

const categories = ['Hair Care', 'Spa & Massage', 'Nail Care', 'Consultation'];

const services = [
  { category: 'Hair Care', name: 'Haircut & Styling', price: 75000, durationMinutes: 60, capacity: 2, description: 'Haircut, wash and styling by a senior stylist.' },
  { category: 'Hair Care', name: 'Hair Coloring', price: 250000, durationMinutes: 120, capacity: 1, description: 'Full hair coloring with premium products.' },
  { category: 'Spa & Massage', name: 'Balinese Massage', price: 180000, durationMinutes: 90, capacity: 2, description: 'Traditional full body massage.' },
  { category: 'Spa & Massage', name: 'Facial Treatment', price: 150000, durationMinutes: 60, capacity: 2, description: 'Deep cleansing facial for all skin types.' },
  { category: 'Nail Care', name: 'Manicure & Pedicure', price: 120000, durationMinutes: 60, capacity: 3, description: 'Nail cleaning, shaping and polish.' },
  { category: 'Consultation', name: 'Beauty Consultation', price: 50000, durationMinutes: 30, capacity: 1, description: 'One on one consultation with a beauty expert.' },
];

// [customerIndex, serviceIndex, dayOffset, slotIndex, finalStatus]
const sampleBookings = [
  [0, 0, -6, 1, 'COMPLETED'],
  [1, 2, -6, 2, 'COMPLETED'],
  [0, 3, -5, 3, 'COMPLETED'],
  [1, 0, -4, 1, 'COMPLETED'],
  [0, 4, -3, 0, 'CANCELLED'],
  [1, 0, -2, 1, 'COMPLETED'],
  [0, 2, -1, 1, 'COMPLETED'],
  [1, 3, 1, 2, 'CONFIRMED'],
  [0, 0, 2, 1, 'PENDING'],
  [1, 5, 3, 4, 'PENDING'],
  [0, 1, 4, 0, 'CONFIRMED'],
];

const TABLES = 'booking_status_logs, payments, bookings, schedules, services, categories, refresh_tokens, users';

const resetTables = () => sequelize.query(`TRUNCATE ${TABLES} RESTART IDENTITY CASCADE`);

const seedUsers = async () => {
  const [adminHash, userHash] = await Promise.all([bcrypt.hash('Admin12345', 10), bcrypt.hash('User12345', 10)]);

  const admin = await User.create({
    name: 'Admin Booking',
    email: 'admin@booking.com',
    phone: '081100000001',
    passwordHash: adminHash,
    role: 'ADMIN',
  });
  const customers = await User.bulkCreate(
    [
      { name: 'Budi Santoso', email: 'budi@example.com', phone: '081234567890' },
      { name: 'Siti Rahma', email: 'siti@example.com', phone: '081298765432' },
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
