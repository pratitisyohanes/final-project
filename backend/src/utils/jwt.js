const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const env = require('../config/env');

// name lets other services (pos-api) print the user on receipts without another request
const signAccessToken = (user) =>
  jwt.sign({ sub: user.id, role: user.role, name: user.name }, env.JWT_ACCESS_SECRET, { expiresIn: env.JWT_ACCESS_EXPIRES });

// jti keeps every refresh token unique even when issued in the same second
const signRefreshToken = (user) =>
  jwt.sign({ sub: user.id, jti: crypto.randomUUID() }, env.JWT_REFRESH_SECRET, { expiresIn: env.JWT_REFRESH_EXPIRES });

const verifyAccessToken = (token) => jwt.verify(token, env.JWT_ACCESS_SECRET);

const verifyRefreshToken = (token) => jwt.verify(token, env.JWT_REFRESH_SECRET);

const getTokenExpiry = (token) => new Date(jwt.decode(token).exp * 1000);

// Refresh tokens are stored as SHA-256 hashes, never in plain text
const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

// Own key derived from the access secret, so an MFA ticket can never pass authenticate() here or in pos-api
const mfaTicketKey = crypto.createHmac('sha256', env.JWT_ACCESS_SECRET).update('mfa-ticket').digest();

// Short ticket that proves the password step passed; purpose is "verify" (has MFA) or "setup" (must enrol)
const signMfaTicket = (user, purpose) =>
  jwt.sign({ sub: user.id, purpose, jti: crypto.randomUUID() }, mfaTicketKey, { expiresIn: '5m' });

const verifyMfaTicket = (token, purpose) => {
  const payload = jwt.verify(token, mfaTicketKey);
  if (payload.purpose !== purpose) throw new Error('Ticket purpose does not match');
  return payload;
};

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  getTokenExpiry,
  hashToken,
  signMfaTicket,
  verifyMfaTicket,
};
