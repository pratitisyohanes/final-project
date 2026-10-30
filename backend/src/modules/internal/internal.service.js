const { sequelize, Booking, Service, Schedule, User, Payment } = require('../../models');
const ApiError = require('../../utils/ApiError');
const reportsService = require('../reports/reports.service');

// Only bookings the farm has accepted can be paid at the POS counter
const SETTLEABLE_STATUSES = ['CONFIRMED', 'COMPLETED'];

const toSummary = (booking) => ({
  id: booking.id,
  bookingCode: booking.bookingCode,
  status: booking.status,
  totalPrice: Number(booking.totalPrice),
  service: { id: booking.service.id, name: booking.service.name },
  schedule: { date: booking.schedule.date, startTime: booking.schedule.startTime, endTime: booking.schedule.endTime },
  customer: { id: booking.user.id, name: booking.user.name, email: booking.user.email, phone: booking.user.phone },
  payment: {
    status: booking.payment.status,
    method: booking.payment.method,
    paidAt: booking.payment.paidAt,
    externalRef: booking.payment.externalRef,
  },
  canSettle: SETTLEABLE_STATUSES.includes(booking.status) && booking.payment.status === 'UNPAID',
});

const getBookingByCode = async (bookingCode, transaction) => {
  const booking = await Booking.findOne({
    where: { bookingCode },
    include: [
      { model: Service, as: 'service', attributes: ['id', 'name'], paranoid: false },
      { model: Schedule, as: 'schedule', attributes: ['date', 'startTime', 'endTime'] },
      { model: User, as: 'user', attributes: ['id', 'name', 'email', 'phone'] },
      { model: Payment, as: 'payment' },
    ],
    transaction,
  });
  if (!booking) throw ApiError.notFound(`Booking ${bookingCode} not found`);
  return toSummary(booking);
};

// Rows are locked without includes because Postgres cannot lock the nullable side of a join
const settleBooking = (bookingCode, { method, amount, externalRef }) =>
  sequelize.transaction(async (transaction) => {
    const booking = await Booking.findOne({ where: { bookingCode }, transaction, lock: transaction.LOCK.UPDATE });
    if (!booking) throw ApiError.notFound(`Booking ${bookingCode} not found`);
    const payment = await Payment.findOne({ where: { bookingId: booking.id }, transaction, lock: transaction.LOCK.UPDATE });

    if (payment.status === 'PAID') {
      // Same invoice again means the POS is retrying, so answer as if it succeeded
      if (payment.externalRef === externalRef) return getBookingByCode(bookingCode, transaction);
      throw ApiError.conflict(`Booking ${bookingCode} is already paid`);
    }
    if (payment.status === 'REFUNDED') throw ApiError.badRequest(`Booking ${bookingCode} was refunded and cannot be paid`);
    if (!SETTLEABLE_STATUSES.includes(booking.status)) {
      throw ApiError.badRequest(`Only confirmed or completed bookings can be paid at the POS (current: ${booking.status})`);
    }
    if (Number(amount) !== Number(booking.totalPrice)) {
      throw ApiError.badRequest(`Amount must equal the booking total of ${Number(booking.totalPrice)}`);
    }

    await payment.update({ status: 'PAID', method, paidAt: new Date(), externalRef }, { transaction });
    return getBookingByCode(bookingCode, transaction);
  });

const getSummary = (query) => reportsService.getSummary(query);

module.exports = { getBookingByCode, settleBooking, getSummary, SETTLEABLE_STATUSES };
