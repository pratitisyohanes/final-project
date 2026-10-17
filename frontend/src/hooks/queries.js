import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { servicesApi } from '../api/services.api';
import { categoriesApi } from '../api/categories.api';
import { schedulesApi } from '../api/schedules.api';
import { bookingsApi } from '../api/bookings.api';
import { usersApi } from '../api/users.api';
import { reportsApi } from '../api/reports.api';
import { cleanParams } from './useUrlFilters';

// Query keys are shared with mutations so they can invalidate the right cache
export const queryKeys = {
  services: ['services'],
  categories: ['categories'],
  schedules: ['schedules'],
  slots: ['slots'],
  bookings: ['bookings'],
  users: ['users'],
  reports: ['reports'],
};

const listQuery = (key, fetcher, params, options = {}) => ({
  queryKey: [...key, 'list', cleanParams(params)],
  queryFn: () => fetcher(cleanParams(params)),
  placeholderData: keepPreviousData,
  ...options,
});

export const useServices = (params) => useQuery(listQuery(queryKeys.services, servicesApi.list, params));

export const useService = (id) =>
  useQuery({ queryKey: [...queryKeys.services, 'detail', id], queryFn: () => servicesApi.getById(id), enabled: !!id });

export const useAvailableSlots = (serviceId, params) =>
  useQuery({
    queryKey: [...queryKeys.slots, serviceId, params],
    queryFn: () => servicesApi.getAvailableSchedules(serviceId, params),
    enabled: !!serviceId,
  });

export const useCategories = (params = { limit: 100 }) =>
  useQuery(listQuery(queryKeys.categories, categoriesApi.list, params, { staleTime: 5 * 60 * 1000 }));

export const useSchedules = (params) => useQuery(listQuery(queryKeys.schedules, schedulesApi.list, params));

export const useMyBookings = (params) =>
  useQuery(listQuery([...queryKeys.bookings, 'mine'], bookingsApi.listMine, params));

export const useAllBookings = (params) =>
  useQuery(listQuery([...queryKeys.bookings, 'all'], bookingsApi.listAll, params));

export const useBooking = (id) =>
  useQuery({ queryKey: [...queryKeys.bookings, 'detail', id], queryFn: () => bookingsApi.getById(id), enabled: !!id });

export const useCustomers = (params) => useQuery(listQuery(queryKeys.users, usersApi.list, params));

export const useCustomer = (id) =>
  useQuery({ queryKey: [...queryKeys.users, 'detail', id], queryFn: () => usersApi.getById(id), enabled: !!id });

const useReportQuery = (name, fetcher, params) =>
  useQuery({
    queryKey: [...queryKeys.reports, name, cleanParams(params)],
    queryFn: () => fetcher(cleanParams(params)),
    placeholderData: keepPreviousData,
  });

export const useReportSummary = (params) => useReportQuery('summary', reportsApi.summary, params);
export const useTopServices = (params) => useReportQuery('top-services', reportsApi.topServices, params);
export const useBusiestSchedules = (params) => useReportQuery('busiest', reportsApi.busiestSchedules, params);
export const useRevenue = (params) => useReportQuery('revenue', reportsApi.revenue, params);
