import { api, getData } from './client';

export const authApi = {
  login: (payload) => api.post('/auth/login', payload).then(getData),
  register: (payload) => api.post('/auth/register', payload).then(getData),
  logout: (refreshToken) => api.post('/auth/logout', { refreshToken }),
  getMe: () => api.get('/auth/me').then(getData),
  updateMe: (payload) => api.patch('/auth/me', payload).then(getData),
};
