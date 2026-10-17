const router = require('express').Router();

router.use('/auth', require('../modules/auth/auth.routes'));
router.use('/users', require('../modules/users/users.routes'));
router.use('/categories', require('../modules/categories/categories.routes'));
router.use('/services', require('../modules/services/services.routes'));
router.use('/schedules', require('../modules/schedules/schedules.routes'));
router.use('/bookings', require('../modules/bookings/bookings.routes'));
router.use('/payments', require('../modules/payments/payments.routes'));
router.use('/reports', require('../modules/reports/reports.routes'));

module.exports = router;
