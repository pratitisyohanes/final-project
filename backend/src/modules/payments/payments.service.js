const { Booking, Payment } = require('../../models');
const ApiError = require('../../utils/ApiError');

// Admin records an offline payment (cash, transfer, e-wallet) for a booking
const markAsPaid = async (bookingId, { method }) => {
  const booking = await Booking.findByPk(bookingId, { include: [{ model: Payment, as: 'payment' }] });
  if (!booking || !booking.payment) throw ApiError.notFound('Booking not found');
  if (booking.status === 'CANCELLED') throw ApiError.badRequest('Cannot record payment for a cancelled booking');
  if (booking.payment.status === 'PAID') throw ApiError.conflict('Payment is already marked as paid');

  await booking.payment.update({ status: 'PAID', method, paidAt: new Date() });

  return Payment.findOne({
    where: { bookingId },
    include: [{ model: Booking, as: 'booking', attributes: ['id', 'bookingCode', 'status'] }],
  });
};

module.exports = { markAsPaid };
