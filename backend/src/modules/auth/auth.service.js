const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const { User, RefreshToken } = require('../../models');
const env = require('../../config/env');
const ApiError = require('../../utils/ApiError');
const compact = require('../../utils/compact');
const {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  getTokenExpiry,
  hashToken,
} = require('../../utils/jwt');

// Create an access/refresh token pair and persist the hashed refresh token
const issueTokens = async (user) => {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  await RefreshToken.create({ userId: user.id, tokenHash: hashToken(refreshToken), expiresAt: getTokenExpiry(refreshToken) });

  return { accessToken, refreshToken };
};

const register = async ({ name, email, phone, password }) => {
  const existing = await User.findOne({ where: { email } });
  if (existing) throw ApiError.conflict('Email is already registered');

  const passwordHash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);
  const user = await User.create({ name, email, phone, passwordHash, role: 'USER' });

  const tokens = await issueTokens(user);
  return { user, ...tokens };
};

const login = async ({ email, password }) => {
  const user = await User.scope('withPassword').findOne({ where: { email } });
  const isValid = user && (await bcrypt.compare(password, user.passwordHash));
  if (!isValid) throw ApiError.unauthorized('Invalid email or password');
  if (!user.isActive) throw ApiError.forbidden('Your account has been deactivated');

  await RefreshToken.destroy({ where: { userId: user.id, expiresAt: { [Op.lt]: new Date() } } });

  const tokens = await issueTokens(user);
  return { user, ...tokens };
};

// Rotate tokens: the old refresh token is deleted and a new pair is issued
const refresh = async (refreshToken) => {
  try {
    verifyRefreshToken(refreshToken);
  } catch {
    throw ApiError.unauthorized('Refresh token is invalid or expired');
  }

  const stored = await RefreshToken.findOne({
    where: { tokenHash: hashToken(refreshToken) },
    include: [{ model: User, as: 'user' }],
  });
  if (!stored || stored.expiresAt < new Date()) throw ApiError.unauthorized('Refresh token is invalid or expired');
  if (!stored.user.isActive) throw ApiError.forbidden('Your account has been deactivated');

  await stored.destroy();

  const tokens = await issueTokens(stored.user);
  return { user: stored.user, ...tokens };
};

const logout = async (userId, refreshToken) => {
  await RefreshToken.destroy({ where: { userId, tokenHash: hashToken(refreshToken) } });
};

const getMe = async (userId) => {
  const user = await User.findByPk(userId);
  if (!user) throw ApiError.notFound('User not found');
  return user;
};

const updateMe = async (userId, { name, phone, currentPassword, newPassword }) => {
  const user = await User.scope('withPassword').findByPk(userId);
  if (!user) throw ApiError.notFound('User not found');

  const data = compact({ name, phone });
  if (newPassword) {
    const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isValid) throw ApiError.badRequest('Current password is incorrect');
    data.passwordHash = await bcrypt.hash(newPassword, env.BCRYPT_ROUNDS);
  }

  return user.update(data);
};

module.exports = { register, login, refresh, logout, getMe, updateMe };
