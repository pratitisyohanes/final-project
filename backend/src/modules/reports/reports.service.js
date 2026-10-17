const { Op, QueryTypes } = require('sequelize');
const { sequelize, Booking, Payment, User, Service, Schedule } = require('../../models');
const toCsv = require('../../utils/csv');
const { resolveDateRange, toDateFilter, toTimestampFilter } = require('../../utils/dateRange');
const { todayWib, toDateString } = require('../../utils/time');

// Bookings that count as real demand in reports
const COUNTED_STATUSES = ['CONFIRMED', 'COMPLETED'];
const DAY_NAMES = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

// Reports default to the current month when no range is given
const getRange = (query) => {
  const range = resolveDateRange(query) || resolveDateRange({ period: 'this_month' });
  return { start: range.start || '1970-01-01', end: range.end || todayWib() };
};

const getSummary = async (query) => {
  const range = getRange(query);
  const createdAt = toTimestampFilter(range);

  const [totalBookings, byStatus, revenue, newCustomers, todayBookings] = await Promise.all([
    Booking.count({ where: { createdAt } }),
    Booking.findAll({
      where: { createdAt },
      attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['status'],
      raw: true,
    }),
    Payment.sum('amount', { where: { status: 'PAID', paidAt: createdAt } }),
    User.count({ where: { role: 'USER', createdAt } }),
    Booking.count({
      where: { status: { [Op.in]: ['PENDING', ...COUNTED_STATUSES] } },
      include: [{ model: Schedule, as: 'schedule', attributes: [], where: { date: todayWib() } }],
    }),
  ]);

  const statusCount = Object.fromEntries(byStatus.map((row) => [row.status, Number(row.count)]));
  const cancelled = statusCount.CANCELLED || 0;

  return {
    range,
    totalBookings,
    bookingsByStatus: { PENDING: 0, CONFIRMED: 0, COMPLETED: 0, CANCELLED: 0, ...statusCount },
    totalRevenue: Number(revenue || 0),
    newCustomers,
    todayBookings,
    cancellationRate: totalBookings ? Number(((cancelled / totalBookings) * 100).toFixed(1)) : 0,
  };
};

// Raw SQL keeps the aggregation readable and includes soft-deleted services in history
const getTopServices = async (query) => {
  const range = getRange(query);
  const items = await sequelize.query(
    `SELECT s.id AS "serviceId", s.name AS "serviceName", c.name AS "categoryName",
            COUNT(b.id)::int AS "totalBookings", COALESCE(SUM(b.total_price), 0)::float AS "totalRevenue"
     FROM bookings b
     JOIN services s ON s.id = b.service_id
     JOIN categories c ON c.id = s.category_id
     JOIN schedules sc ON sc.id = b.schedule_id
     WHERE b.status::text IN (:statuses) AND sc.date BETWEEN :start AND :end
     GROUP BY s.id, s.name, c.name
     ORDER BY "totalBookings" DESC, s.name
     LIMIT :limit`,
    { replacements: { statuses: COUNTED_STATUSES, start: range.start, end: range.end, limit: query.limit }, type: QueryTypes.SELECT },
  );
  return { range, items };
};

const getBusiestSchedules = async (query) => {
  const range = getRange(query);
  const replacements = { statuses: COUNTED_STATUSES, start: range.start, end: range.end, limit: query.limit };

  const byDayAndTime = await sequelize.query(
    `SELECT EXTRACT(ISODOW FROM sc.date)::int AS "dayOfWeek", sc.start_time AS "startTime", COUNT(b.id)::int AS "totalBookings"
     FROM bookings b
     JOIN schedules sc ON sc.id = b.schedule_id
     WHERE b.status::text IN (:statuses) AND sc.date BETWEEN :start AND :end
     GROUP BY 1, 2
     ORDER BY 3 DESC, 1, 2
     LIMIT :limit`,
    { replacements, type: QueryTypes.SELECT },
  );

  const byDate = await sequelize.query(
    `SELECT to_char(sc.date, 'YYYY-MM-DD') AS "date", COUNT(b.id)::int AS "totalBookings"
     FROM bookings b
     JOIN schedules sc ON sc.id = b.schedule_id
     WHERE b.status::text IN (:statuses) AND sc.date BETWEEN :start AND :end
     GROUP BY sc.date
     ORDER BY 2 DESC, 1
     LIMIT :limit`,
    { replacements, type: QueryTypes.SELECT },
  );

  return {
    range,
    byDayAndTime: byDayAndTime.map((row) => ({ ...row, dayName: DAY_NAMES[row.dayOfWeek] })),
    byDate,
  };
};

// Revenue per day or month from paid payments, grouped in WIB
const getRevenue = async (query) => {
  const range = getRange(query);
  const payments = await Payment.findAll({
    where: { status: 'PAID', paidAt: toTimestampFilter(range) },
    attributes: ['amount', 'paidAt'],
    raw: true,
  });

  const keyLength = query.groupBy === 'month' ? 7 : 10;
  const buckets = new Map();
  payments.forEach(({ amount, paidAt }) => {
    const key = toDateString(new Date(new Date(paidAt).getTime() + 7 * 60 * 60 * 1000)).slice(0, keyLength);
    const bucket = buckets.get(key) || { period: key, revenue: 0, transactions: 0 };
    bucket.revenue += Number(amount);
    bucket.transactions += 1;
    buckets.set(key, bucket);
  });

  const items = [...buckets.values()].sort((a, b) => a.period.localeCompare(b.period));
  return { range, groupBy: query.groupBy, total: items.reduce((sum, item) => sum + item.revenue, 0), items };
};

const exportReport = async (query) => {
  const range = getRange(query);

  if (query.type === 'top-services') {
    const { items } = await getTopServices({ ...query, limit: 50 });
    const csv = toCsv(items, [
      { header: 'Service', value: (r) => r.serviceName },
      { header: 'Category', value: (r) => r.categoryName },
      { header: 'Total Bookings', value: (r) => r.totalBookings },
      { header: 'Total Revenue', value: (r) => r.totalRevenue },
    ]);
    return { filename: `top-services_${range.start}_${range.end}.csv`, csv };
  }

  const bookings = await Booking.findAll({
    order: [['createdAt', 'ASC']],
    include: [
      { model: User, as: 'user', attributes: ['name', 'email'] },
      { model: Service, as: 'service', attributes: ['name'], paranoid: false },
      { model: Schedule, as: 'schedule', attributes: ['date', 'startTime', 'endTime'], where: { date: toDateFilter(range) } },
      { model: Payment, as: 'payment', attributes: ['status', 'method'] },
    ],
  });

  const csv = toCsv(bookings, [
    { header: 'Booking Code', value: (b) => b.bookingCode },
    { header: 'Customer', value: (b) => b.user.name },
    { header: 'Email', value: (b) => b.user.email },
    { header: 'Service', value: (b) => b.service.name },
    { header: 'Date', value: (b) => b.schedule.date },
    { header: 'Time', value: (b) => `${b.schedule.startTime}-${b.schedule.endTime}` },
    { header: 'Status', value: (b) => b.status },
    { header: 'Total Price', value: (b) => Number(b.totalPrice) },
    { header: 'Payment Status', value: (b) => b.payment?.status },
    { header: 'Payment Method', value: (b) => b.payment?.method },
  ]);
  return { filename: `bookings_${range.start}_${range.end}.csv`, csv };
};

module.exports = { getSummary, getTopServices, getBusiestSchedules, getRevenue, exportReport };
