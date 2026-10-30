import { useState } from 'react';
import { useLocation } from 'react-router-dom';
import toast from 'react-hot-toast';
import { startLogin } from '../utils/oidc';
import AuthCard from './AuthCard';
import Button from './ui/Button';

// Login and sign-up when single sign-on is on: both continue on the KandangID page and come back to /login/callback
export default function SsoLogin({ mode = 'login', subtitle }) {
  const location = useLocation();
  const [isLeaving, setIsLeaving] = useState(false);
  const isRegister = mode === 'register';
  // The page that asked for login; empty means "go to the home page for my role"
  const returnTo = location.state?.from?.pathname || null;

  const go = (prompt) => {
    setIsLeaving(true);
    startLogin({ returnTo, prompt }).catch(() => {
      setIsLeaving(false);
      toast.error('Could not open the KandangID login page');
    });
  };

  return (
    <AuthCard
      title={isRegister ? 'Create account' : 'Log in'}
      subtitle={subtitle}
      footer={
        <>
          {isRegister ? 'Already have an account? ' : 'No account yet? '}
          <button type="button" onClick={() => go(isRegister ? undefined : 'create')} className="font-medium text-brand-700 hover:underline">
            {isRegister ? 'Log in' : 'Create one'}
          </button>
        </>
      }
    >
      <div className="space-y-4">
        <p className="text-sm text-slate-600">
          KandangMart Booking and POS share one account. You continue on the KandangID page and come back here; if you are already logged in there, it takes a second.
        </p>
        <Button className="w-full" size="lg" isLoading={isLeaving} onClick={() => go(isRegister ? 'create' : undefined)}>
          {isRegister ? 'Create account with KandangID' : 'Log in with KandangID'}
        </Button>
      </div>
    </AuthCard>
  );
}
