const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate, optionalAuthenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./services.controller');
const schedulesController = require('../schedules/schedules.controller');
const { availableSchedulesSchema } = require('../schedules/schedules.schema');
const {
  listServicesSchema,
  serviceIdSchema,
  createServiceSchema,
  updateServiceSchema,
} = require('./services.schema');

const adminOnly = [authenticate, authorize('ADMIN')];

router.get('/', optionalAuthenticate, validate(listServicesSchema), controller.listServices);
router.get('/:id', optionalAuthenticate, validate(serviceIdSchema), controller.getService);
router.get('/:id/schedules', validate(availableSchedulesSchema), schedulesController.listAvailableSchedules);
router.post('/', adminOnly, validate(createServiceSchema), controller.createService);
router.patch('/:id', adminOnly, validate(updateServiceSchema), controller.updateService);
router.delete('/:id', adminOnly, validate(serviceIdSchema), controller.deleteService);

module.exports = router;
