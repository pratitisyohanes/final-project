const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./payments.controller');
const { markAsPaidSchema } = require('./payments.schema');

router.patch('/:bookingId', authenticate, authorize('ADMIN'), validate(markAsPaidSchema), controller.markAsPaid);

module.exports = router;
