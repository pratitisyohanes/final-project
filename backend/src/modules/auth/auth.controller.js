const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const authService = require('./auth.service');

const register = asyncHandler(async (req, res) => {
  const data = await authService.register(req.body);
  success(res, { statusCode: 201, message: 'Registration successful', data });
});

const login = asyncHandler(async (req, res) => {
  const data = await authService.login(req.body);
  success(res, { message: 'Login successful', data });
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
  const data = await authService.updateMe(req.user.id, req.body);
  success(res, { message: 'Profile updated', data });
});

module.exports = { register, login, refresh, logout, getMe, updateMe };
