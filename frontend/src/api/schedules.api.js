import { api, getData, getList } from './client';

export const schedulesApi = {
  list: (params) => api.get('/schedules', { params }).then(getList),
  create: (payload) => api.post('/schedules', payload).then(getData),
  bulkCreate: (payload) => api.post('/schedules/bulk', payload).then(getData),
  update: (id, payload) => api.patch(`/schedules/${id}`, payload).then(getData),
  remove: (id) => api.delete(`/schedules/${id}`),
};
