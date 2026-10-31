const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { addDays, todayWib, toDateTime, generateSlots } = require('../../utils/time');

const BOOKING_COUNT = 50;
const CODE_PREFIX = 'BK-DEMO-';
const DEFAULT_CAPACITY = 2;

const CUSTOMERS = [
  ['Andi Pratama', 'andi.pratama@example.com', '081311110001'],
  ['Dewi Lestari', 'dewi.lestari@example.com', '081311110002'],
  ['Rudi Hartono', 'rudi.hartono@example.com', '081311110003'],
  ['Rina Wulandari', 'rina.wulandari@example.com', '081311110004'],
  ['Agus Setiawan', 'agus.setiawan@example.com', '081311110005'],
  ['Maya Kusuma', 'maya.kusuma@example.com', '081311110006'],
  ['Hendra Wijaya', 'hendra.wijaya@example.com', '081311110007'],
  ['Lestari Ningsih', 'lestari.ningsih@example.com', '081311110008'],
  ['Fajar Nugroho', 'fajar.nugroho@example.com', '081311110009'],
  ['Putri Anggraini', 'putri.anggraini@example.com', '081311110010'],
];

// Deterministic pseudo-random plan so every environment gets the same 50 bookings
// Extra candidates are planned because a few land on full slots and are skipped
const PLAN_SIZE = BOOKING_COUNT * 2;

const buildPlan = () => {
  let seed = 20261031;
  const next = (max) => {
    seed = (seed * 1664525 + 1013904223) % 4294967296;
    return seed % max;
  };
  return Array.from({ length: PLAN_SIZE }, () => {
    const dayOffset = next(17) - 6;
    let status;
    if (dayOffset < 0) status = next(100) < 80 ? 'COMPLETED' : 'CANCELLED';
    else {
      const roll = next(100);
      status = roll < 40 ? 'PENDING' : roll < 90 ? 'CONFIRMED' : 'CANCELLED';
    }
    const method = ['TRANSFER', 'EWALLET', 'CASH'][next(3)];
    return { customer: next(CUSTOMERS.length), service: next(1000), dayOffset, slot: next(4), status, method };
  });
};

const buildLogs = (status, customerId, adminId) => {
  const logs = [{ from: null, to: 'PENDING', by: customerId, note: 'Booking created' }];
  if (status === 'CONFIRMED' || status === 'COMPLETED') logs.push({ from: 'PENDING', to: 'CONFIRMED', by: adminId, note: null });
  if (status === 'COMPLETED') logs.push({ from: 'CONFIRMED', to: 'COMPLETED', by: adminId, note: null });
  if (status === 'CANCELLED') logs.push({ from: 'PENDING', to: 'CANCELLED', by: customerId, note: 'Cancelled by customer' });
  return logs;
};

// Sample data for demos; safe to run more than once because users and booking codes are checked first
module.exports = {
  async up(queryInterface) {
    const { sequelize } = queryInterface;
    const q = (sql, replacements, options = {}) => sequelize.query(sql, { replacements, ...options });
    const rows = (sql, replacements, options = {}) => q(sql, replacements, { type: 'SELECT', ...options });

    await sequelize.transaction(async (transaction) => {
      const services = await rows(
        "SELECT id, price, duration_minutes FROM services WHERE deleted_at IS NULL AND status = 'ACTIVE' ORDER BY id",
        {},
        { transaction },
      );
      if (!services.length) return; // nothing to book against on an empty catalog

      const passwordHash = await bcrypt.hash('User12345', 10);
      for (const [name, email, phone] of CUSTOMERS) {
        await q(
          `INSERT INTO users (id, name, email, phone, password_hash, role, is_active, created_at, updated_at)
           VALUES (:id, :name, :email, :phone, :passwordHash, 'USER', true, NOW(), NOW())
           ON CONFLICT (email) DO NOTHING`,
          { id: crypto.randomUUID(), name, email, phone, passwordHash },
          { transaction },
        );
      }
      const idByEmail = Object.fromEntries(
        (await rows('SELECT id, email FROM users WHERE email IN (:emails)', { emails: CUSTOMERS.map(([, email]) => email) }, { transaction })).map((u) => [u.email, u.id]),
      );

      const [admin] = await rows("SELECT id FROM users WHERE role = 'ADMIN' ORDER BY created_at LIMIT 1", {}, { transaction });
      const adminId = admin ? admin.id : null;
      const today = todayWib();

      let placed = 0;
      for (const plan of buildPlan()) {
        if (placed >= BOOKING_COUNT) break;
        const code = `${CODE_PREFIX}${String(placed + 1).padStart(4, '0')}`;
        const [existing] = await rows('SELECT id FROM bookings WHERE booking_code = :code', { code }, { transaction });
        if (existing) {
          placed += 1;
          continue;
        }

        const service = services[plan.service % services.length];
        const date = addDays(today, plan.dayOffset);

        let slots = await rows(
          "SELECT id, start_time, capacity, booked_count FROM schedules WHERE service_id = :serviceId AND date = :date AND status <> 'CLOSED' ORDER BY start_time",
          { serviceId: service.id, date },
          { transaction },
        );
        if (!slots.length) {
          // The date has no schedule yet, so open the normal 09:00-17:00 slots for this service
          for (const slot of generateSlots('09:00', '17:00', service.duration_minutes)) {
            await q(
              `INSERT INTO schedules (service_id, date, start_time, end_time, capacity, booked_count, status, created_at, updated_at)
               VALUES (:serviceId, :date, :startTime, :endTime, :capacity, 0, 'AVAILABLE', NOW(), NOW())`,
              { serviceId: service.id, date, startTime: slot.startTime, endTime: slot.endTime, capacity: DEFAULT_CAPACITY },
              { transaction },
            );
          }
          slots = await rows(
            "SELECT id, start_time, capacity, booked_count FROM schedules WHERE service_id = :serviceId AND date = :date AND status <> 'CLOSED' ORDER BY start_time",
            { serviceId: service.id, date },
            { transaction },
          );
        }
        if (!slots.length) continue;

        // Start at the planned slot and move on until one has room, so no schedule is overbooked
        const start = plan.slot % slots.length;
        const slot = [...slots.slice(start), ...slots.slice(0, start)].find((s) => s.booked_count < s.capacity);
        if (!slot) continue;

        const customerEmail = CUSTOMERS[plan.customer][1];
        const customerId = idByEmail[customerEmail];
        const slotStart = toDateTime(date, slot.start_time);
        const createdAt = new Date(slotStart.getTime() - 24 * 60 * 60 * 1000);
        const isPaid = plan.status === 'COMPLETED' || plan.status === 'CONFIRMED';
        const bookingId = crypto.randomUUID();
        placed += 1;

        await q(
          `INSERT INTO bookings (id, booking_code, user_id, service_id, schedule_id, total_price, status, created_at, updated_at)
           VALUES (:id, :code, :userId, :serviceId, :scheduleId, :price, :status, :createdAt, :createdAt)`,
          { id: bookingId, code, userId: customerId, serviceId: service.id, scheduleId: slot.id, price: service.price, status: plan.status, createdAt },
          { transaction },
        );
        await q(
          `INSERT INTO payments (id, booking_id, amount, method, status, paid_at, created_at, updated_at)
           VALUES (:id, :bookingId, :price, :method, :status, :paidAt, :createdAt, :createdAt)`,
          {
            id: crypto.randomUUID(),
            bookingId,
            price: service.price,
            method: isPaid ? plan.method : null,
            status: isPaid ? 'PAID' : 'UNPAID',
            paidAt: isPaid ? new Date(Math.min(slotStart.getTime(), Date.now())) : null,
            createdAt,
          },
          { transaction },
        );
        for (const log of buildLogs(plan.status, customerId, adminId)) {
          await q(
            `INSERT INTO booking_status_logs (booking_id, from_status, to_status, changed_by, note, created_at)
             VALUES (:bookingId, :from, :to, :by, :note, :createdAt)`,
            { bookingId, from: log.from, to: log.to, by: log.by, note: log.note, createdAt },
            { transaction },
          );
        }

        if (plan.status !== 'CANCELLED') {
          await q(
            `UPDATE schedules SET booked_count = booked_count + 1,
               status = CASE WHEN booked_count + 1 >= capacity THEN 'FULL' ELSE status END
             WHERE id = :id`,
            { id: slot.id },
            { transaction },
          );
        }
      }
    });
  },

  async down(queryInterface) {
    const { sequelize } = queryInterface;
    await sequelize.transaction(async (transaction) => {
      // Payments and status logs go with their booking through ON DELETE CASCADE
      await sequelize.query('DELETE FROM bookings WHERE booking_code LIKE :prefix', {
        replacements: { prefix: `${CODE_PREFIX}%` },
        transaction,
      });
      await sequelize.query('DELETE FROM users WHERE email IN (:emails)', {
        replacements: { emails: CUSTOMERS.map(([, email]) => email) },
        transaction,
      });
      // Recount seats so slots freed by the removed bookings open up again
      await sequelize.query(
        `UPDATE schedules s SET
           booked_count = c.cnt,
           status = (CASE WHEN s.status = 'CLOSED' THEN 'CLOSED' WHEN c.cnt >= s.capacity THEN 'FULL' ELSE 'AVAILABLE' END)::enum_schedules_status
         FROM (
           SELECT sc.id, COUNT(b.id) FILTER (WHERE b.status <> 'CANCELLED') AS cnt
           FROM schedules sc LEFT JOIN bookings b ON b.schedule_id = sc.id
           GROUP BY sc.id
         ) c
         WHERE c.id = s.id AND s.booked_count <> c.cnt`,
        { transaction },
      );
    });
  },
};
