import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Access token stays in memory; only the user and refresh token survive a page reload
export const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      setSession: ({ user, accessToken, refreshToken }) => set({ user, accessToken, refreshToken }),
      setUser: (user) => set({ user }),
      clearSession: () => set({ user: null, accessToken: null, refreshToken: null }),
    }),
    {
      name: 'booking-auth',
      partialize: (state) => ({ user: state.user, refreshToken: state.refreshToken }),
    },
  ),
);

export const selectIsAdmin = (state) => state.user?.role === 'ADMIN';
