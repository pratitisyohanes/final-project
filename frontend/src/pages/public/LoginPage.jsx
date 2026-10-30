import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { authApi } from '../../api/auth.api';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useAuthStore } from '../../store/authStore';
import { loginSchema } from '../../schemas/auth.schema';
import { applyFieldErrors } from '../../utils/errors';
import { isSsoEnabled } from '../../utils/oidc';
import AuthCard from '../../components/AuthCard';
import MfaStep from '../../components/MfaStep';
import SsoLogin from '../../components/SsoLogin';
import Button from '../../components/ui/Button';
import { Input } from '../../components/ui/FormField';

const DEMO_ACCOUNTS = [
  { label: 'Admin', email: 'admin@booking.com', password: 'Admin12345' },
  { label: 'Customer', email: 'budi@example.com', password: 'User12345' },
];

// With single sign-on the password is typed on the KandangID page, not here
export default function LoginPage() {
  return isSsoEnabled ? <SsoLogin subtitle="Access your bookings or the admin panel." /> : <PasswordLoginPage />;
}

function PasswordLoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const setSession = useAuthStore((state) => state.setSession);
  // Set when the password was right but a second step (code or authenticator setup) is still needed
  const [challenge, setChallenge] = useState(null);

  const {
    register,
    handleSubmit,
    setValue,
    setError,
    formState: { errors },
  } = useForm({ resolver: zodResolver(loginSchema), defaultValues: { email: '', password: '' } });

  const completeLogin = (session) => {
    setSession(session);
    toast.success(`Welcome back, ${session.user.name}`);
    // Return to the page that required login, otherwise go to the role home page
    const fallback = session.user.role === 'ADMIN' ? '/admin' : '/my-bookings';
    navigate(location.state?.from?.pathname || fallback, { replace: true });
  };

  const login = useApiMutation(authApi.login, {
    onSuccess: (result) => (result.mfaToken ? setChallenge(result) : completeLogin(result)),
  });

  const onSubmit = (values) => login.mutate(values, { onError: (error) => applyFieldErrors(error, setError) });

  const fillDemo = (account) => {
    setValue('email', account.email);
    setValue('password', account.password);
  };

  if (challenge) {
    return (
      <AuthCard title={challenge.requiresMfaSetup ? 'Set up two-factor login' : 'Two-factor verification'} subtitle="One more step to protect your account.">
        <MfaStep challenge={challenge} onSession={completeLogin} onCancel={() => setChallenge(null)} />
      </AuthCard>
    );
  }

  return (
    <AuthCard
      title="Log in"
      subtitle="Access your bookings or the admin panel."
      footer={
        <>
          No account yet?{' '}
          <Link to="/register" className="font-medium text-brand-700 hover:underline">
            Sign up
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
        <Input id="email" type="email" label="Email" autoComplete="email" error={errors.email?.message} {...register('email')} />
        <Input id="password" type="password" label="Password" autoComplete="current-password" error={errors.password?.message} {...register('password')} />
        <Button type="submit" className="w-full" isLoading={login.isPending}>
          Log in
        </Button>
      </form>

      <div className="mt-6 rounded-lg bg-slate-50 p-3 text-xs text-slate-500">
        <p className="font-medium text-slate-600">Demo accounts</p>
        <div className="mt-2 flex flex-wrap gap-2">
          {DEMO_ACCOUNTS.map((account) => (
            <button key={account.email} type="button" onClick={() => fillDemo(account)} className="rounded border border-slate-200 bg-white px-2 py-1 hover:border-brand-500">
              {account.label}: {account.email}
            </button>
          ))}
        </div>
      </div>
    </AuthCard>
  );
}
