import { api, getData, getList } from './client';

export const servicesApi = {
  list: (params) => api.get('/services', { params }).then(getList),
  getById: (id) => api.get(`/services/${id}`).then(getData),
  getAvailableSchedules: (id, params) => api.get(`/services/${id}/schedules`, { params }).then(getData),
  create: (payload) => api.post('/services', payload).then(getData),
  update: (id, payload) => api.patch(`/services/${id}`, payload).then(getData),
  remove: (id) => api.delete(`/services/${id}`),
};
