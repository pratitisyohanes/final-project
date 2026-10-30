const router = require('express').Router();
const validate = require('../../middlewares/validate');
const { authenticate } = require('../../middlewares/authenticate');
const { authLimiter } = require('../../middlewares/rateLimiter');
const controller = require('./auth.controller');
const {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  updateMeSchema,
  mfaTicketSchema,
  mfaCodeSchema,
} = require('./auth.schema');

router.post('/register', authLimiter, validate(registerSchema), controller.register);
router.post('/login', authLimiter, validate(loginSchema), controller.login);

// Second step after /login answered requiresMfa or requiresMfaSetup; all need the mfaToken ticket
router.post('/mfa/verify', authLimiter, validate(mfaCodeSchema), controller.verifyMfa);
router.post('/mfa/setup', authLimiter, validate(mfaTicketSchema), controller.setupMfa);
router.post('/mfa/enable', authLimiter, validate(mfaCodeSchema), controller.enableMfa);

router.post('/refresh', validate(refreshTokenSchema), controller.refresh);
router.post('/logout', authenticate, validate(refreshTokenSchema), controller.logout);
router.get('/me', authenticate, controller.getMe);
router.patch('/me', authenticate, validate(updateMeSchema), controller.updateMe);

module.exports = router;
