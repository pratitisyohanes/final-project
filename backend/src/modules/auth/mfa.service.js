const { authenticator } = require('otplib');
const QRCode = require('qrcode');
const { User } = require('../../models');
const env = require('../../config/env');
const ApiError = require('../../utils/ApiError');
const { encrypt, decrypt } = require('../../utils/secretBox');
const { signMfaTicket, verifyMfaTicket } = require('../../utils/jwt');

// Accept the previous, current and next 30-second code to allow for clock drift on the phone
authenticator.options = { window: 1 };

const STEP_MS = 30 * 1000;
const MAX_ATTEMPTS = 5;

// Wrong codes per ticket (jti); kept in memory because booking-api runs as a single PM2 process
const attempts = new Map();

const pruneAttempts = () => {
  const now = Date.now();
  attempts.forEach((entry, jti) => entry.expiresAt < now && attempts.delete(jti));
};

const countAttempt = (ticket) => {
  pruneAttempts();
  const entry = attempts.get(ticket.jti) || { count: 0, expiresAt: ticket.exp * 1000 };
  entry.count += 1;
  attempts.set(ticket.jti, entry);
  if (entry.count > MAX_ATTEMPTS) throw new ApiError(429, 'Too many wrong codes, please log in again');
};

const invalidCode = () => new ApiError(400, 'Invalid verification code', [{ field: 'code', message: 'Invalid verification code' }]);

// The ticket replaces ERM's email field: without a passed password step there is no ticket (fixes the MFA bypass)
const readTicket = (token, purpose) => {
  try {
    return verifyMfaTicket(token, purpose);
  } catch {
    throw ApiError.unauthorized('Verification session expired, please log in again');
  }
};

const loadUser = async (id) => {
  const user = await User.scope('withPassword').findByPk(id);
  if (!user || !user.isActive) throw ApiError.unauthorized('Verification session expired, please log in again');
  return user;
};

// Returns the accepted time step, or null; a step at or before the last one is a replayed code
const acceptCode = (user, secret, code) => {
  const delta = authenticator.checkDelta(code, secret);
  if (delta === null) return null;
  const step = Math.floor(Date.now() / STEP_MS) + delta;
  if (user.mfaLastStep !== null && user.mfaLastStep !== undefined && step <= Number(user.mfaLastStep)) return null;
  return step;
};

// Decide what the password step answers: nothing extra, a code prompt, or a forced setup for admins
const challengeFor = (user) => {
  if (user.mfaEnabled) return { requiresMfa: true, mfaToken: signMfaTicket(user, 'verify') };
  if (user.role === 'ADMIN' && env.MFA_ENFORCE_ADMIN) return { requiresMfaSetup: true, mfaToken: signMfaTicket(user, 'setup') };
  return null;
};

const verifyLogin = async (mfaToken, code) => {
  const ticket = readTicket(mfaToken, 'verify');
  countAttempt(ticket);
  const user = await loadUser(ticket.sub);
  if (!user.mfaEnabled || !user.mfaSecret) throw ApiError.unauthorized('Verification session expired, please log in again');

  const step = acceptCode(user, decrypt(user.mfaSecret), code);
  if (step === null) throw invalidCode();

  attempts.delete(ticket.jti);
  return user.update({ mfaLastStep: step });
};

// Step 1 of enrolment: a new secret is stored encrypted but not active until a code proves the phone has it
const startSetup = async (mfaToken) => {
  const ticket = readTicket(mfaToken, 'setup');
  const user = await loadUser(ticket.sub);
  if (user.mfaEnabled) throw ApiError.conflict('Two-factor authentication is already active');

  const secret = authenticator.generateSecret();
  await user.update({ mfaSecret: encrypt(secret), mfaLastStep: null });

  const otpauthUrl = authenticator.keyuri(user.email, env.MFA_ISSUER, secret);
  return { secret, otpauthUrl, qrCode: await QRCode.toDataURL(otpauthUrl) };
};

// Step 2 of enrolment: the first valid code switches MFA on and completes the login
const finishSetup = async (mfaToken, code) => {
  const ticket = readTicket(mfaToken, 'setup');
  countAttempt(ticket);
  const user = await loadUser(ticket.sub);
  if (user.mfaEnabled) throw ApiError.conflict('Two-factor authentication is already active');
  if (!user.mfaSecret) throw ApiError.badRequest('Start the setup first');

  const step = acceptCode(user, decrypt(user.mfaSecret), code);
  if (step === null) throw invalidCode();

  attempts.delete(ticket.jti);
  return user.update({ mfaEnabled: true, mfaSetupAt: new Date(), mfaLastStep: step });
};

module.exports = { challengeFor, verifyLogin, startSetup, finishSetup };
