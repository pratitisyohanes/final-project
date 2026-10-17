import axios from 'axios';
import { useAuthStore } from '../store/authStore';

const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

export const api = axios.create({ baseURL });

// Separate instance without interceptors so a failed refresh cannot trigger another refresh
const refreshClient = axios.create({ baseURL });

// Unwrap the backend envelope { success, message, data, meta }
export const getData = (response) => response.data.data;
export const getList = (response) => ({ items: response.data.data, meta: response.data.meta });

api.interceptors.request.use((config) => {
  const { accessToken } = useAuthStore.getState();
  if (accessToken) config.headers.Authorization = `Bearer ${accessToken}`;
  return config;
});

let refreshPromise = null;

// Parallel 401 responses share one refresh call because the backend rotates refresh tokens
export const refreshSession = () => {
  const { refreshToken, setSession } = useAuthStore.getState();
  if (!refreshToken) return Promise.reject(new Error('No refresh token'));

  if (!refreshPromise) {
    refreshPromise = refreshClient
      .post('/auth/refresh', { refreshToken })
      .then((response) => {
        setSession(getData(response));
        return getData(response).accessToken;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }
  return refreshPromise;
};

const AUTH_PATHS = ['/auth/login', '/auth/register', '/auth/refresh'];

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config;
    const isAuthPath = AUTH_PATHS.some((path) => original?.url?.startsWith(path));

    if (error.response?.status !== 401 || !original || original._retry || isAuthPath) {
      return Promise.reject(error);
    }

    original._retry = true;
    try {
      const accessToken = await refreshSession();
      original.headers.Authorization = `Bearer ${accessToken}`;
      return api(original);
    } catch {
      useAuthStore.getState().clearSession();
      return Promise.reject(error);
    }
  },
);
