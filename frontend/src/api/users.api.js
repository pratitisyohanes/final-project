import { api, getData, getList } from './client';

export const usersApi = {
  list: (params) => api.get('/users', { params }).then(getList),
  getById: (id) => api.get(`/users/${id}`).then(getData),
  update: (id, payload) => api.patch(`/users/${id}`, payload).then(getData),
};
