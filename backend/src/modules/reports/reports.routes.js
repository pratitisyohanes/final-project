const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./reports.controller');
const { summarySchema, topListSchema, revenueSchema, exportSchema } = require('./reports.schema');

router.use(authenticate, authorize('ADMIN'));

router.get('/summary', validate(summarySchema), controller.getSummary);
router.get('/top-services', validate(topListSchema), controller.getTopServices);
router.get('/busiest-schedules', validate(topListSchema), controller.getBusiestSchedules);
router.get('/revenue', validate(revenueSchema), controller.getRevenue);
router.get('/export', validate(exportSchema), controller.exportReport);

module.exports = router;
