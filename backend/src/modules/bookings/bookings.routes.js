const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./bookings.controller');
const {
  createBookingSchema,
  listMyBookingsSchema,
  listBookingsSchema,
  bookingIdSchema,
  cancelBookingSchema,
  updateBookingStatusSchema,
} = require('./bookings.schema');

router.use(authenticate);

router.post('/', authorize('USER'), validate(createBookingSchema), controller.createBooking);
router.get('/me', authorize('USER'), validate(listMyBookingsSchema), controller.listMyBookings);
router.get('/', authorize('ADMIN'), validate(listBookingsSchema), controller.listBookings);
router.get('/:id', validate(bookingIdSchema), controller.getBooking);
router.patch('/:id/cancel', validate(cancelBookingSchema), controller.cancelBooking);
router.patch('/:id/status', authorize('ADMIN'), validate(updateBookingStatusSchema), controller.updateBookingStatus);

module.exports = router;
