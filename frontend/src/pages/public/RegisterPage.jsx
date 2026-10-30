import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { authApi } from '../../api/auth.api';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useAuthStore } from '../../store/authStore';
import { registerSchema } from '../../schemas/auth.schema';
import { applyFieldErrors } from '../../utils/errors';
import { isSsoEnabled } from '../../utils/oidc';
import AuthCard from '../../components/AuthCard';
import SsoLogin from '../../components/SsoLogin';
import Button from '../../components/ui/Button';
import { Input } from '../../components/ui/FormField';

// With single sign-on the account is created on the KandangID page (it becomes an LDAP entry)
export default function RegisterPage() {
  return isSsoEnabled ? <SsoLogin mode="register" subtitle="Book site surveys, cage installation and repairs." /> : <PasswordRegisterPage />;
}

function PasswordRegisterPage() {
  const navigate = useNavigate();
  const setSession = useAuthStore((state) => state.setSession);

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(registerSchema),
    defaultValues: { name: '', email: '', phone: '', password: '', confirmPassword: '' },
  });

  const signUp = useApiMutation(authApi.register, {
    onSuccess: (session) => {
      setSession(session);
      toast.success('Account created. You can book a service now.');
      navigate('/services', { replace: true });
    },
  });

  // confirmPassword is only for the form; phone is optional on the backend
  const onSubmit = ({ confirmPassword, phone, ...values }) =>
    signUp.mutate({ ...values, phone: phone || undefined }, { onError: (error) => applyFieldErrors(error, setError) });

  return (
    <AuthCard
      title="Create an account"
      subtitle="Sign up to book services and track your history."
      footer={
        <>
          Already have an account?{' '}
          <Link to="/login" className="font-medium text-brand-700 hover:underline">
            Log in
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
        <Input id="name" label="Full name" autoComplete="name" error={errors.name?.message} {...register('name')} />
        <Input id="email" type="email" label="Email" autoComplete="email" error={errors.email?.message} {...register('email')} />
        <Input id="phone" type="tel" label="Phone (optional)" autoComplete="tel" placeholder="081234567890" error={errors.phone?.message} {...register('phone')} />
        <Input
          id="password"
          type="password"
          label="Password"
          autoComplete="new-password"
          hint="At least 8 characters with a letter and a number"
          error={errors.password?.message}
          {...register('password')}
        />
        <Input id="confirmPassword" type="password" label="Confirm password" autoComplete="new-password" error={errors.confirmPassword?.message} {...register('confirmPassword')} />
        <Button type="submit" className="w-full" isLoading={signUp.isPending}>
          Sign up
        </Button>
      </form>
    </AuthCard>
  );
}
