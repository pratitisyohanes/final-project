const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const bookingsService = require('./bookings.service');

const createBooking = asyncHandler(async (req, res) => {
  const data = await bookingsService.createBooking(req.user.id, req.body);
  success(res, { statusCode: 201, message: 'Booking created', data });
});

const listMyBookings = asyncHandler(async (req, res) => {
  const { items, meta } = await bookingsService.listMyBookings(req.user.id, req.query);
  success(res, { message: 'My bookings', data: items, meta });
});

const listBookings = asyncHandler(async (req, res) => {
  const { items, meta } = await bookingsService.listBookings(req.query);
  success(res, { message: 'Booking list', data: items, meta });
});

const getBooking = asyncHandler(async (req, res) => {
  const data = await bookingsService.getBookingById(req.params.id, req.user);
  success(res, { message: 'Booking detail', data });
});

const cancelBooking = asyncHandler(async (req, res) => {
  const data = await bookingsService.cancelBooking(req.params.id, req.user, req.body.reason);
  success(res, { message: 'Booking cancelled', data });
});

const updateBookingStatus = asyncHandler(async (req, res) => {
  const data = await bookingsService.updateBookingStatus(req.params.id, req.body, req.user.id);
  success(res, { message: `Booking status changed to ${data.status}`, data });
});

module.exports = { createBooking, listMyBookings, listBookings, getBooking, cancelBooking, updateBookingStatus };
