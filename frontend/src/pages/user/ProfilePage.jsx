import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { authApi } from '../../api/auth.api';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useAuthStore } from '../../store/authStore';
import { passwordSchema, profileSchema } from '../../schemas/auth.schema';
import { applyFieldErrors } from '../../utils/errors';
import PageHeader from '../../components/ui/PageHeader';
import Card from '../../components/ui/Card';
import Button from '../../components/ui/Button';
import { Input } from '../../components/ui/FormField';

function ProfileForm({ user, onSaved }) {
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isDirty },
  } = useForm({ resolver: zodResolver(profileSchema), values: { name: user.name, phone: user.phone || '' } });

  const update = useApiMutation(authApi.updateMe, { successMessage: 'Profile updated', onSuccess: onSaved });

  const onSubmit = ({ name, phone }) => update.mutate({ name, phone: phone || null }, { onError: (error) => applyFieldErrors(error, setError) });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
      <Input id="profile-email" label="Email" value={user.email} disabled readOnly />
      <Input id="profile-name" label="Full name" error={errors.name?.message} {...register('name')} />
      <Input id="profile-phone" type="tel" label="Phone" error={errors.phone?.message} {...register('phone')} />
      <Button type="submit" disabled={!isDirty} isLoading={update.isPending}>
        Save changes
      </Button>
    </form>
  );
}

function PasswordForm() {
  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors },
  } = useForm({ resolver: zodResolver(passwordSchema), defaultValues: { currentPassword: '', newPassword: '', confirmPassword: '' } });

  const update = useApiMutation(authApi.updateMe, { successMessage: 'Password changed', onSuccess: () => reset() });

  const onSubmit = ({ currentPassword, newPassword }) =>
    update.mutate({ currentPassword, newPassword }, { onError: (error) => applyFieldErrors(error, setError) });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
      <Input id="currentPassword" type="password" label="Current password" autoComplete="current-password" error={errors.currentPassword?.message} {...register('currentPassword')} />
      <Input id="newPassword" type="password" label="New password" autoComplete="new-password" error={errors.newPassword?.message} {...register('newPassword')} />
      <Input id="confirmNewPassword" type="password" label="Confirm new password" autoComplete="new-password" error={errors.confirmPassword?.message} {...register('confirmPassword')} />
      <Button type="submit" isLoading={update.isPending}>
        Change password
      </Button>
    </form>
  );
}

export default function ProfilePage() {
  const user = useAuthStore((state) => state.user);
  const setUser = useAuthStore((state) => state.setUser);

  return (
    <div className="space-y-6">
      <PageHeader title="Profile" description="Manage your personal information and password." />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card title="Personal information">
          <ProfileForm user={user} onSaved={setUser} />
        </Card>
        <Card title="Change password">
          <PasswordForm />
        </Card>
      </div>
    </div>
  );
}
