import { api, getData, getList } from './client';

export const bookingsApi = {
  create: (payload) => api.post('/bookings', payload).then(getData),
  listMine: (params) => api.get('/bookings/me', { params }).then(getList),
  listAll: (params) => api.get('/bookings', { params }).then(getList),
  getById: (id) => api.get(`/bookings/${id}`).then(getData),
  cancel: (id, reason) => api.patch(`/bookings/${id}/cancel`, { reason }).then(getData),
  updateStatus: (id, payload) => api.patch(`/bookings/${id}/status`, payload).then(getData),
  markAsPaid: (id, method) => api.patch(`/payments/${id}`, { method }).then(getData),
};
