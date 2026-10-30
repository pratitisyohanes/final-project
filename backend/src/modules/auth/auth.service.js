const { Op } = require('sequelize');
const { User, RefreshToken } = require('../../models');
const ApiError = require('../../utils/ApiError');
const provider = require('./providers');
const mfaService = require('./mfa.service');
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

// Last step of every successful login, whatever the provider and whether MFA was needed
const startSession = async (user) => {
  await RefreshToken.destroy({ where: { userId: user.id, expiresAt: { [Op.lt]: new Date() } } });
  await user.update({ lastLoginAt: new Date() });

  const tokens = await issueTokens(user);
  return { user, ...tokens };
};

const register = async (data, context) => {
  const user = await provider.register(data, context);
  return startSession(user);
};

// Password step: either a full session, or a ticket for the MFA step (no access token yet)
const login = async (credentials, context) => {
  const user = await provider.authenticate(credentials, context);
  if (!user.isActive) throw ApiError.forbidden('Your account has been deactivated');

  const challenge = mfaService.challengeFor(user);
  if (challenge) return challenge;
  return startSession(user);
};

const verifyMfa = async ({ mfaToken, code }) => startSession(await mfaService.verifyLogin(mfaToken, code));

const setupMfa = ({ mfaToken }) => mfaService.startSetup(mfaToken);

const enableMfa = async ({ mfaToken, code }) => startSession(await mfaService.finishSetup(mfaToken, code));

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

  // With sso this re-reads LDAP; a user moved to cn=disabled loses every session here
  let user;
  try {
    user = await provider.syncOnRefresh(stored.user);
  } catch (error) {
    if (error.statusCode === 403) await RefreshToken.destroy({ where: { userId: stored.user.id } });
    throw error;
  }

  await stored.destroy();

  const tokens = await issueTokens(user);
  return { user, ...tokens };
};

const logout = async (userId, refreshToken) => {
  await RefreshToken.destroy({ where: { userId, tokenHash: hashToken(refreshToken) } });
};

const getMe = async (userId) => {
  const user = await User.findByPk(userId);
  if (!user) throw ApiError.notFound('User not found');
  return user;
};

const updateMe = async (userId, data, context) => {
  const user = await User.scope('withPassword').findByPk(userId);
  if (!user) throw ApiError.notFound('User not found');
  return provider.updateProfile(user, data, context);
};

module.exports = { register, login, verifyMfa, setupMfa, enableMfa, refresh, logout, getMe, updateMe };
