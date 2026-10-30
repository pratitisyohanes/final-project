import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { authApi } from '../../api/auth.api';
import { useAuthStore } from '../../store/authStore';
import { finishLogin, startLogin } from '../../utils/oidc';
import AuthCard from '../../components/AuthCard';
import Button from '../../components/ui/Button';
import { PageLoader } from '../../components/ui/Spinner';

const homeFor = (role) => (role === 'ADMIN' ? '/admin' : '/my-bookings');

// KandangID sends the browser here with ?code&state after login
export default function AuthCallbackPage() {
  const navigate = useNavigate();
  const setSession = useAuthStore((state) => state.setSession);
  const setUser = useAuthStore((state) => state.setUser);
  const [error, setError] = useState(null);
  const started = useRef(false);

  useEffect(() => {
    // StrictMode runs effects twice in development, but a code can only be exchanged once
    if (started.current) return;
    started.current = true;

    finishLogin(window.location.search)
      .then(async ({ session, returnTo }) => {
        setSession(session);
        // The first API call also creates the local profile; it brings back fields such as phone
        const profile = await authApi.getMe().catch(() => null);
        if (profile) setUser(profile);
        toast.success(`Welcome, ${session.user.name}`);
        navigate(returnTo || homeFor(session.user.role), { replace: true });
      })
      .catch((err) => setError(err.message));
  }, [navigate, setSession, setUser]);

  if (error) {
    return (
      <AuthCard title="Login did not finish" subtitle={error}>
        <Button className="w-full" onClick={() => startLogin()}>
          Try again
        </Button>
      </AuthCard>
    );
  }
  return <PageLoader label="Finishing login..." />;
}
