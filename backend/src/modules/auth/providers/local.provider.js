const bcrypt = require('bcryptjs');
const { User } = require('../../../models');
const env = require('../../../config/env');
const ApiError = require('../../../utils/ApiError');
const compact = require('../../../utils/compact');

// AUTH_PROVIDER=local: passwords are bcrypt hashes in booking_db (behaviour before sso-pro)
const authenticate = async ({ email, password }) => {
  const user = await User.scope('withPassword').findOne({ where: { email } });
  const isValid = user?.passwordHash && (await bcrypt.compare(password, user.passwordHash));
  if (!isValid) throw ApiError.unauthorized('Invalid email or password');
  return user;
};

const register = async ({ name, email, phone, password }) => {
  const existing = await User.findOne({ where: { email } });
  if (existing) throw ApiError.conflict('Email is already registered');

  const passwordHash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);
  return User.create({ name, email, phone, passwordHash, role: 'USER' });
};

// user is loaded with the withPassword scope
const updateProfile = async (user, { name, phone, currentPassword, newPassword }) => {
  const data = compact({ name, phone });
  if (newPassword) {
    const isValid = user.passwordHash && (await bcrypt.compare(currentPassword, user.passwordHash));
    if (!isValid) throw ApiError.badRequest('Current password is incorrect');
    data.passwordHash = await bcrypt.hash(newPassword, env.BCRYPT_ROUNDS);
  }
  return user.update(data);
};

// Nothing outside booking_db can change a local account
const syncOnRefresh = async (user) => user;

module.exports = { authenticate, register, updateProfile, syncOnRefresh };
