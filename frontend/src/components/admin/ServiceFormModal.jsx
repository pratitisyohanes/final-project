import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { servicesApi } from '../../api/services.api';
import { queryKeys, useCategories } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { serviceSchema } from '../../schemas/admin.schema';
import { SERVICE_STATUS, toOptions } from '../../utils/constants';
import { applyFieldErrors } from '../../utils/errors';
import Modal from '../ui/Modal';
import Button from '../ui/Button';
import { Input, Select, Textarea } from '../ui/FormField';

const toFormValues = (service) => ({
  categoryId: service?.categoryId ? String(service.categoryId) : '',
  name: service?.name || '',
  description: service?.description || '',
  price: service ? Number(service.price) : '',
  durationMinutes: service?.durationMinutes || 60,
  status: service?.status || 'ACTIVE',
  imageUrl: service?.imageUrl || '',
});

export default function ServiceFormModal({ isOpen, service, onClose }) {
  const isEdit = !!service;
  const categories = useCategories();
  const categoryOptions = (categories.data?.items || []).map((category) => ({ value: String(category.id), label: category.name }));

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm({ resolver: zodResolver(serviceSchema), values: toFormValues(service) });

  const save = useApiMutation((payload) => (isEdit ? servicesApi.update(service.id, payload) : servicesApi.create(payload)), {
    invalidate: [queryKeys.services, queryKeys.categories],
    successMessage: isEdit ? 'Service updated' : 'Service created',
    onSuccess: onClose,
  });

  // Empty optional fields are sent as null so the backend clears them
  const onSubmit = ({ description, imageUrl, ...values }) =>
    save.mutate(
      { ...values, description: description || null, imageUrl: imageUrl || null },
      { onError: (error) => applyFieldErrors(error, setError) },
    );

  return (
    <Modal
      isOpen={isOpen}
      size="lg"
      title={isEdit ? 'Edit service' : 'New service'}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="service-form" isLoading={save.isPending}>
            Save
          </Button>
        </>
      }
    >
      <form id="service-form" onSubmit={handleSubmit(onSubmit)} className="grid gap-4 sm:grid-cols-2" noValidate>
        <div className="sm:col-span-2">
          <Input id="service-name" label="Name" error={errors.name?.message} {...register('name')} />
        </div>
        <Select id="service-category" label="Category" placeholder="Select a category" options={categoryOptions} error={errors.categoryId?.message} {...register('categoryId')} />
        <Select id="service-status" label="Status" options={toOptions(SERVICE_STATUS)} error={errors.status?.message} {...register('status')} />
        <Input id="service-price" type="number" min="0" step="1000" label="Price (Rp)" error={errors.price?.message} {...register('price')} />
        <Input id="service-duration" type="number" min="15" step="15" label="Duration (minutes)" error={errors.durationMinutes?.message} {...register('durationMinutes')} />
        <div className="sm:col-span-2">
          <Input id="service-image" type="url" label="Image URL (optional)" placeholder="https://..." error={errors.imageUrl?.message} {...register('imageUrl')} />
        </div>
        <div className="sm:col-span-2">
          <Textarea id="service-description" label="Description" rows={4} error={errors.description?.message} {...register('description')} />
        </div>
      </form>
    </Modal>
  );
}
