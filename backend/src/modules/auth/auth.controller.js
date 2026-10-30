const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const authService = require('./auth.service');

// The end user's IP travels to auth-service so its audit log shows who tried to log in
const contextOf = (req) => ({ ip: req.ip });

const register = asyncHandler(async (req, res) => {
  const data = await authService.register(req.body, contextOf(req));
  success(res, { statusCode: 201, message: 'Registration successful', data });
});

const login = asyncHandler(async (req, res) => {
  const data = await authService.login(req.body, contextOf(req));
  let message = 'Login successful';
  if (data.requiresMfa) message = 'Enter the code from your authenticator app';
  if (data.requiresMfaSetup) message = 'Set up two-factor authentication to continue';
  success(res, { message, data });
});

const verifyMfa = asyncHandler(async (req, res) => {
  const data = await authService.verifyMfa(req.body);
  success(res, { message: 'Login successful', data });
});

const setupMfa = asyncHandler(async (req, res) => {
  const data = await authService.setupMfa(req.body);
  success(res, { message: 'Scan the QR code with your authenticator app', data });
});

const enableMfa = asyncHandler(async (req, res) => {
  const data = await authService.enableMfa(req.body);
  success(res, { message: 'Two-factor authentication enabled', data });
});

const refresh = asyncHandler(async (req, res) => {
  const data = await authService.refresh(req.body.refreshToken);
  success(res, { message: 'Token refreshed', data });
});

const logout = asyncHandler(async (req, res) => {
  await authService.logout(req.user.id, req.body.refreshToken);
  success(res, { message: 'Logout successful' });
});

const getMe = asyncHandler(async (req, res) => {
  const data = await authService.getMe(req.user.id);
  success(res, { message: 'Current user profile', data });
});

const updateMe = asyncHandler(async (req, res) => {
  const data = await authService.updateMe(req.user.id, req.body, contextOf(req));
  success(res, { message: 'Profile updated', data });
});

module.exports = { register, login, verifyMfa, setupMfa, enableMfa, refresh, logout, getMe, updateMe };
