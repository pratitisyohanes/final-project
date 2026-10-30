const router = require('express').Router();
const validate = require('../../middlewares/validate');
const authenticateService = require('../../middlewares/authenticateService');
const controller = require('./internal.controller');
const { bookingCodeSchema, settleBookingSchema, summarySchema } = require('./internal.schema');

// Every route here is for pos-api only; Nginx also returns 404 for /api/v1/internal from outside
router.use(authenticateService);

router.get('/bookings/:code', validate(bookingCodeSchema), controller.getBooking);
router.post('/bookings/:code/settle', validate(settleBookingSchema), controller.settleBooking);
router.get('/reports/summary', validate(summarySchema), controller.getSummary);

module.exports = router;
