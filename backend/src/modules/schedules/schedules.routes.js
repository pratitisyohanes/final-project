const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./schedules.controller');
const {
  listSchedulesSchema,
  scheduleIdSchema,
  createScheduleSchema,
  bulkCreateSchedulesSchema,
  updateScheduleSchema,
} = require('./schedules.schema');

// Schedule management is admin only; customers use GET /services/:id/schedules
router.use(authenticate, authorize('ADMIN'));

router.get('/', validate(listSchedulesSchema), controller.listSchedules);
router.post('/', validate(createScheduleSchema), controller.createSchedule);
router.post('/bulk', validate(bulkCreateSchedulesSchema), controller.bulkCreateSchedules);
router.get('/:id', validate(scheduleIdSchema), controller.getSchedule);
router.patch('/:id', validate(updateScheduleSchema), controller.updateSchedule);
router.delete('/:id', validate(scheduleIdSchema), controller.deleteSchedule);

module.exports = router;
