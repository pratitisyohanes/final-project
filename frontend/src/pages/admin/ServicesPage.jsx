import { useState } from 'react';
import { servicesApi } from '../../api/services.api';
import { queryKeys, useCategories, useServices } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import ServiceFormModal from '../../components/admin/ServiceFormModal';
import PageHeader from '../../components/ui/PageHeader';
import DataTable from '../../components/ui/DataTable';
import Pagination from '../../components/ui/Pagination';
import SearchInput from '../../components/ui/SearchInput';
import ConfirmDialog from '../../components/ui/ConfirmDialog';
import Button from '../../components/ui/Button';
import { StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/FormField';
import { SERVICE_STATUS, toOptions } from '../../utils/constants';
import { formatDuration, formatRupiah } from '../../utils/format';

export default function ServicesPage() {
  const [filters, setFilters] = useUrlFilters();
  const [editing, setEditing] = useState(null);
  const [deleting, setDeleting] = useState(null);

  const services = useServices({ ...filters, limit: 10 });
  const categories = useCategories();
  const categoryOptions = (categories.data?.items || []).map((category) => ({ value: category.id, label: category.name }));

  const remove = useApiMutation((id) => servicesApi.remove(id), {
    invalidate: [queryKeys.services, queryKeys.categories],
    successMessage: 'Service deleted',
    onSuccess: () => setDeleting(null),
  });

  const columns = [
    { key: 'name', header: 'Name', render: (row) => <span className="font-medium text-slate-800">{row.name}</span> },
    { key: 'category', header: 'Category', render: (row) => row.category?.name },
    { key: 'price', header: 'Price', className: 'whitespace-nowrap', render: (row) => formatRupiah(row.price) },
    { key: 'durationMinutes', header: 'Duration', className: 'whitespace-nowrap', render: (row) => formatDuration(row.durationMinutes) },
    { key: 'status', header: 'Status', render: (row) => <StatusBadge status={row.status} map={SERVICE_STATUS} /> },
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
      <PageHeader title="Services" description="Manage service type, price and duration." actions={<Button onClick={() => setEditing({})}>New service</Button>} />

      <div className="grid gap-3 rounded-xl border border-slate-200 bg-white p-4 sm:grid-cols-3">
        <SearchInput value={filters.search || ''} onChange={(search) => setFilters({ search })} placeholder="Search services" />
        <Select id="categoryId" aria-label="Category" options={categoryOptions} placeholder="All categories" value={filters.categoryId || ''} onChange={(event) => setFilters({ categoryId: event.target.value })} />
        <Select id="status" aria-label="Status" options={toOptions(SERVICE_STATUS)} placeholder="All statuses" value={filters.status || ''} onChange={(event) => setFilters({ status: event.target.value })} />
      </div>

      <DataTable columns={columns} rows={services.data?.items} isLoading={services.isLoading} error={services.error} onRetry={services.refetch} emptyTitle="No services found" />
      <Pagination meta={services.data?.meta} onPageChange={(page) => setFilters({ page })} />

      {/* Mounted only while open so the form always starts from fresh values */}
      {editing && <ServiceFormModal isOpen service={editing.id ? editing : null} onClose={() => setEditing(null)} />}

      <ConfirmDialog
        isOpen={!!deleting}
        title="Delete service?"
        message={`"${deleting?.name}" will be hidden from customers. Booking history is kept.`}
        confirmLabel="Delete"
        isLoading={remove.isPending}
        onConfirm={() => remove.mutate(deleting.id)}
        onClose={() => setDeleting(null)}
      />
    </>
  );
}
