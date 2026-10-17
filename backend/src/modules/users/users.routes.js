const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const authorize = require('../../middlewares/authorize');
const controller = require('./users.controller');
const { listUsersSchema, userIdSchema, updateUserSchema } = require('./users.schema');

// Every customer management route is admin only
router.use(authenticate, authorize('ADMIN'));

router.get('/', validate(listUsersSchema), controller.listCustomers);
router.get('/:id', validate(userIdSchema), controller.getCustomer);
router.patch('/:id', validate(updateUserSchema), controller.updateCustomer);

module.exports = router;
