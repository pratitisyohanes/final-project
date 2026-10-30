import { api, getData } from './client';

export const authApi = {
  login: (payload) => api.post('/auth/login', payload).then(getData),
  // Second login step; every call carries the mfaToken ticket returned by login
  mfaVerify: (payload) => api.post('/auth/mfa/verify', payload).then(getData),
  mfaSetup: (payload) => api.post('/auth/mfa/setup', payload).then(getData),
  mfaEnable: (payload) => api.post('/auth/mfa/enable', payload).then(getData),
  register: (payload) => api.post('/auth/register', payload).then(getData),
  logout: (refreshToken) => api.post('/auth/logout', { refreshToken }),
  getMe: () => api.get('/auth/me').then(getData),
  updateMe: (payload) => api.patch('/auth/me', payload).then(getData),
};
