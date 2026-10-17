import { api, getData, getList } from './client';

export const categoriesApi = {
  list: (params) => api.get('/categories', { params }).then(getList),
  create: (payload) => api.post('/categories', payload).then(getData),
  update: (id, payload) => api.patch(`/categories/${id}`, payload).then(getData),
  remove: (id) => api.delete(`/categories/${id}`),
};
