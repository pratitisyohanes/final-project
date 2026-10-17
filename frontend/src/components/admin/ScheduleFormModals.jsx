import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import toast from 'react-hot-toast';
import { schedulesApi } from '../../api/schedules.api';
import { queryKeys } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { bulkScheduleSchema, scheduleSchema, scheduleUpdateSchema } from '../../schemas/admin.schema';
import { DAYS_OF_WEEK } from '../../utils/constants';
import { applyFieldErrors } from '../../utils/errors';
import { addDays, today } from '../../utils/format';
import Modal from '../ui/Modal';
import Button from '../ui/Button';
import { Input, Select } from '../ui/FormField';

const invalidate = [queryKeys.schedules, queryKeys.slots];

function FormModal({ isOpen, title, formId, isLoading, onClose, children }) {
  return (
    <Modal
      isOpen={isOpen}
      title={title}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form={formId} isLoading={isLoading}>
            Save
          </Button>
        </>
      }
    >
      {children}
    </Modal>
  );
}

// Single slot: end time is calculated by the backend from the service duration
export function ScheduleCreateModal({ isOpen, serviceOptions, onClose }) {
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm({ resolver: zodResolver(scheduleSchema), defaultValues: { serviceId: '', date: today(), startTime: '09:00', capacity: 1 } });

  const create = useApiMutation(schedulesApi.create, { invalidate, successMessage: 'Schedule created', onSuccess: onClose });
  const onSubmit = (values) => create.mutate(values, { onError: (error) => applyFieldErrors(error, setError) });

  return (
    <FormModal isOpen={isOpen} title="New schedule" formId="schedule-form" isLoading={create.isPending} onClose={onClose}>
      <form id="schedule-form" onSubmit={handleSubmit(onSubmit)} className="grid gap-4 sm:grid-cols-2" noValidate>
        <div className="sm:col-span-2">
          <Select id="schedule-service" label="Service" placeholder="Select a service" options={serviceOptions} error={errors.serviceId?.message} {...register('serviceId')} />
        </div>
        <Input id="schedule-date" type="date" label="Date" min={today()} error={errors.date?.message} {...register('date')} />
        <Input id="schedule-start" type="time" label="Start time" error={errors.startTime?.message} {...register('startTime')} />
        <Input id="schedule-capacity" type="number" min="1" max="100" label="Capacity" error={errors.capacity?.message} {...register('capacity')} />
      </form>
    </FormModal>
  );
}

// Generate back-to-back slots between open and close time for many days at once
export function ScheduleBulkModal({ isOpen, serviceOptions, onClose }) {
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(bulkScheduleSchema),
    defaultValues: {
      serviceId: '',
      startDate: today(),
      endDate: addDays(today(), 6),
      openTime: '09:00',
      closeTime: '17:00',
      capacity: 1,
      daysOfWeek: ['1', '2', '3', '4', '5', '6'],
    },
  });

  const bulkCreate = useApiMutation(schedulesApi.bulkCreate, {
    invalidate,
    onSuccess: ({ created, skipped }) => {
      toast.success(`${created} slot(s) created, ${skipped} skipped`);
      onClose();
    },
  });

  const onSubmit = ({ daysOfWeek, ...values }) =>
    bulkCreate.mutate({ ...values, daysOfWeek: daysOfWeek.map(Number) }, { onError: (error) => applyFieldErrors(error, setError) });

  return (
    <FormModal isOpen={isOpen} title="Generate schedules" formId="bulk-form" isLoading={bulkCreate.isPending} onClose={onClose}>
      <form id="bulk-form" onSubmit={handleSubmit(onSubmit)} className="grid gap-4 sm:grid-cols-2" noValidate>
        <div className="sm:col-span-2">
          <Select id="bulk-service" label="Service" placeholder="Select a service" options={serviceOptions} error={errors.serviceId?.message} {...register('serviceId')} />
        </div>
        <Input id="bulk-start-date" type="date" label="Start date" min={today()} error={errors.startDate?.message} {...register('startDate')} />
        <Input id="bulk-end-date" type="date" label="End date" hint="Maximum 31 days" error={errors.endDate?.message} {...register('endDate')} />
        <Input id="bulk-open" type="time" label="Open time" error={errors.openTime?.message} {...register('openTime')} />
        <Input id="bulk-close" type="time" label="Close time" error={errors.closeTime?.message} {...register('closeTime')} />
        <Input id="bulk-capacity" type="number" min="1" max="100" label="Capacity per slot" error={errors.capacity?.message} {...register('capacity')} />
        <fieldset className="sm:col-span-2">
          <legend className="text-sm font-medium text-slate-700">Days</legend>
          <div className="mt-2 flex flex-wrap gap-2">
            {DAYS_OF_WEEK.map((day) => (
              <label key={day.value} className="flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-sm has-[:checked]:border-brand-500 has-[:checked]:bg-brand-50">
                <input type="checkbox" value={day.value} className="accent-brand-600" {...register('daysOfWeek')} />
                {day.label}
              </label>
            ))}
          </div>
          {errors.daysOfWeek && <p className="mt-1 text-xs text-red-600">{errors.daysOfWeek.message}</p>}
        </fieldset>
      </form>
    </FormModal>
  );
}

export function ScheduleEditModal({ schedule, onClose }) {
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(scheduleUpdateSchema),
    values: schedule && {
      date: schedule.date,
      startTime: schedule.startTime,
      capacity: schedule.capacity,
      status: schedule.status === 'CLOSED' ? 'CLOSED' : 'AVAILABLE',
    },
  });

  const update = useApiMutation((payload) => schedulesApi.update(schedule.id, payload), {
    invalidate,
    successMessage: 'Schedule updated',
    onSuccess: onClose,
  });

  // Only send date/time when changed, because the backend refuses to move a booked slot
  const onSubmit = ({ date, startTime, ...values }) => {
    const payload = { ...values };
    if (date !== schedule.date) payload.date = date;
    if (startTime !== schedule.startTime) payload.startTime = startTime;
    update.mutate(payload, { onError: (error) => applyFieldErrors(error, setError) });
  };

  const isBooked = schedule?.bookedCount > 0;

  return (
    <FormModal isOpen={!!schedule} title="Edit schedule" formId="schedule-edit-form" isLoading={update.isPending} onClose={onClose}>
      <form id="schedule-edit-form" onSubmit={handleSubmit(onSubmit)} className="grid gap-4 sm:grid-cols-2" noValidate>
        <Input id="edit-date" type="date" label="Date" disabled={isBooked} error={errors.date?.message} {...register('date')} />
        <Input id="edit-start" type="time" label="Start time" disabled={isBooked} error={errors.startTime?.message} {...register('startTime')} />
        <Input
          id="edit-capacity"
          type="number"
          min={Math.max(schedule?.bookedCount || 1, 1)}
          max="100"
          label="Capacity"
          hint={isBooked ? `${schedule.bookedCount} seat(s) already booked` : undefined}
          error={errors.capacity?.message}
          {...register('capacity')}
        />
        <Select
          id="edit-status"
          label="Status"
          options={[
            { value: 'AVAILABLE', label: 'Open for booking' },
            { value: 'CLOSED', label: 'Closed' },
          ]}
          error={errors.status?.message}
          {...register('status')}
        />
        {isBooked && <p className="text-xs text-slate-500 sm:col-span-2">Date and time are locked because this slot already has bookings.</p>}
      </form>
    </FormModal>
  );
}
