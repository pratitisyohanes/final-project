import { useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { authApi } from '../api/auth.api';
import { useAuthStore } from '../store/authStore';

export const useLogout = () => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return async () => {
    const { refreshToken, clearSession } = useAuthStore.getState();
    // Local logout must still work when the server call fails
    await authApi.logout(refreshToken).catch(() => null);
    clearSession();
    queryClient.clear();
    toast.success('You have been logged out');
    navigate('/login');
  };
};
