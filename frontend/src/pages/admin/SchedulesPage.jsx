import { useState } from 'react';
import { schedulesApi } from '../../api/schedules.api';
import { queryKeys, useSchedules, useServices } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import { ScheduleBulkModal, ScheduleCreateModal, ScheduleEditModal } from '../../components/admin/ScheduleFormModals';
import DateRangeFilter from '../../components/DateRangeFilter';
import PageHeader from '../../components/ui/PageHeader';
import DataTable from '../../components/ui/DataTable';
import Pagination from '../../components/ui/Pagination';
import ConfirmDialog from '../../components/ui/ConfirmDialog';
import Button from '../../components/ui/Button';
import { StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/FormField';
import { SCHEDULE_STATUS, toOptions } from '../../utils/constants';
import { formatDate } from '../../utils/format';

export default function SchedulesPage() {
  const [filters, setFilters] = useUrlFilters();
  const [openModal, setOpenModal] = useState(null);
  const [editing, setEditing] = useState(null);
  const [deleting, setDeleting] = useState(null);

  const schedules = useSchedules({ ...filters, limit: 15 });
  const services = useServices({ limit: 100, status: 'ACTIVE' });
  const serviceOptions = (services.data?.items || []).map((service) => ({ value: String(service.id), label: service.name }));

  const remove = useApiMutation((id) => schedulesApi.remove(id), {
    invalidate: [queryKeys.schedules, queryKeys.slots],
    successMessage: 'Schedule deleted',
    onSuccess: () => setDeleting(null),
  });

  const columns = [
    { key: 'service', header: 'Service', render: (row) => <span className="font-medium text-slate-800">{row.service?.name}</span> },
    { key: 'date', header: 'Date', className: 'whitespace-nowrap', render: (row) => formatDate(row.date) },
    { key: 'time', header: 'Time', className: 'whitespace-nowrap', render: (row) => `${row.startTime} - ${row.endTime}` },
    { key: 'seats', header: 'Booked', className: 'tabular-nums', render: (row) => `${row.bookedCount} / ${row.capacity}` },
    { key: 'status', header: 'Status', render: (row) => <StatusBadge status={row.status} map={SCHEDULE_STATUS} /> },
    {
      key: 'actions',
      header: '',
      className: 'text-right whitespace-nowrap',
      render: (row) => (
        <div className="flex justify-end gap-1">
          <Button variant="ghost" size="sm" onClick={() => setEditing(row)}>
            Edit
          </Button>
          <Button variant="ghost" size="sm" className="text-red-600" onClick={() => setDeleting(row)}>
            Delete
          </Button>
        </div>
      ),
    },
  ];

  return (
    <>
      <PageHeader
        title="Schedules"
        description="Set when each service can be booked."
        actions={
          <>
            <Button variant="secondary" onClick={() => setOpenModal('single')}>
              Add slot
            </Button>
            <Button onClick={() => setOpenModal('bulk')}>Generate slots</Button>
          </>
        }
      />

      <div className="grid gap-3 rounded-xl border border-slate-200 bg-white p-4 lg:grid-cols-3">
        <div className="grid grid-cols-2 gap-2">
          <Select id="serviceId" aria-label="Service" options={serviceOptions} placeholder="All services" value={filters.serviceId || ''} onChange={(event) => setFilters({ serviceId: event.target.value })} />
          <Select id="status" aria-label="Status" options={toOptions(SCHEDULE_STATUS)} placeholder="All statuses" value={filters.status || ''} onChange={(event) => setFilters({ status: event.target.value })} />
        </div>
        <div className="lg:col-span-2">
          <DateRangeFilter filters={filters} setFilters={setFilters} />
        </div>
      </div>

      <DataTable
        columns={columns}
        rows={schedules.data?.items}
        isLoading={schedules.isLoading}
        error={schedules.error}
        onRetry={schedules.refetch}
        emptyTitle="No schedules found"
        emptyDescription="Use Generate slots to create a week of schedules at once."
      />
      <Pagination meta={schedules.data?.meta} onPageChange={(page) => setFilters({ page })} />

      {openModal === 'single' && <ScheduleCreateModal isOpen serviceOptions={serviceOptions} onClose={() => setOpenModal(null)} />}
      {openModal === 'bulk' && <ScheduleBulkModal isOpen serviceOptions={serviceOptions} onClose={() => setOpenModal(null)} />}
      {editing && <ScheduleEditModal schedule={editing} onClose={() => setEditing(null)} />}

      <ConfirmDialog
        isOpen={!!deleting}
        title="Delete schedule?"
        message="Schedules that already have bookings cannot be deleted. Close them instead."
        confirmLabel="Delete"
        isLoading={remove.isPending}
        onConfirm={() => remove.mutate(deleting.id)}
        onClose={() => setDeleting(null)}
      />
    </>
  );
}
