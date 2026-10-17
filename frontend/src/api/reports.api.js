import { api, getData } from './client';

export const reportsApi = {
  summary: (params) => api.get('/reports/summary', { params }).then(getData),
  topServices: (params) => api.get('/reports/top-services', { params }).then(getData),
  busiestSchedules: (params) => api.get('/reports/busiest-schedules', { params }).then(getData),
  revenue: (params) => api.get('/reports/revenue', { params }).then(getData),
  // CSV export needs the auth header, so it is fetched as a blob instead of a plain link
  exportCsv: (params) => api.get('/reports/export', { params, responseType: 'blob' }),
};
