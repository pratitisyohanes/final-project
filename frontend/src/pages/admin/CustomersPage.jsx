import { useState } from 'react';
import { Link } from 'react-router-dom';
import { usersApi } from '../../api/users.api';
import { queryKeys, useCustomer, useCustomers } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import PageHeader from '../../components/ui/PageHeader';
import DataTable from '../../components/ui/DataTable';
import Pagination from '../../components/ui/Pagination';
import SearchInput from '../../components/ui/SearchInput';
import ConfirmDialog from '../../components/ui/ConfirmDialog';
import Modal from '../../components/ui/Modal';
import Button from '../../components/ui/Button';
import Badge, { StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { BOOKING_STATUS } from '../../utils/constants';
import { formatDate, formatDateTime } from '../../utils/format';

const ACTIVE_OPTIONS = [
  { value: 'true', label: 'Active' },
  { value: 'false', label: 'Inactive' },
];

function CustomerDetailModal({ customerId, onClose }) {
  const customer = useCustomer(customerId);
  const data = customer.data;

  return (
    <Modal isOpen title="Customer detail" size="lg" onClose={onClose}>
      {customer.isLoading || !data ? (
        <PageLoader />
      ) : (
        <div className="space-y-5">
          <dl className="grid gap-3 text-sm sm:grid-cols-2">
            <div>
              <dt className="text-slate-500">Name</dt>
              <dd className="font-medium">{data.name}</dd>
            </div>
            <div>
              <dt className="text-slate-500">Email</dt>
              <dd className="font-medium">{data.email}</dd>
            </div>
            <div>
              <dt className="text-slate-500">Phone</dt>
              <dd className="font-medium">{data.phone || '-'}</dd>
            </div>
            <div>
              <dt className="text-slate-500">Joined</dt>
              <dd className="font-medium">{formatDateTime(data.createdAt)}</dd>
            </div>
          </dl>
          <div>
            <h3 className="mb-2 text-sm font-semibold text-slate-700">Latest bookings ({Number(data.bookingCount || 0)} total)</h3>
            {data.bookings?.length ? (
              <ul className="divide-y divide-slate-100 rounded-lg border border-slate-200">
                {data.bookings.map((booking) => (
                  <li key={booking.id}>
                    <Link to={`/admin/bookings/${booking.id}`} className="flex items-center justify-between gap-3 px-3 py-2 text-sm hover:bg-slate-50">
                      <span>
                        {booking.service?.name}
                        <span className="block text-xs text-slate-500">
                          {formatDate(booking.schedule?.date)} {booking.schedule?.startTime}
                        </span>
                      </span>
                      <StatusBadge status={booking.status} map={BOOKING_STATUS} />
                    </Link>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-sm text-slate-500">No bookings yet.</p>
            )}
          </div>
        </div>
      )}
    </Modal>
  );
}

export default function CustomersPage() {
  const [filters, setFilters] = useUrlFilters();
  const [viewingId, setViewingId] = useState(null);
  const [toggling, setToggling] = useState(null);

  const customers = useCustomers({ ...filters, limit: 10 });

  const toggleActive = useApiMutation((customer) => usersApi.update(customer.id, { isActive: !customer.isActive }), {
    invalidate: [queryKeys.users],
    successMessage: 'Customer status updated',
    onSuccess: () => setToggling(null),
  });

  const columns = [
    {
      key: 'name',
      header: 'Customer',
      render: (row) => (
        <button type="button" className="text-left" onClick={() => setViewingId(row.id)}>
          <span className="block font-medium text-brand-700 hover:underline">{row.name}</span>
          <span className="text-xs text-slate-400">{row.email}</span>
        </button>
      ),
    },
    { key: 'phone', header: 'Phone', render: (row) => row.phone || '-' },
    { key: 'bookingCount', header: 'Bookings', className: 'tabular-nums', render: (row) => Number(row.bookingCount || 0) },
    { key: 'isActive', header: 'Status', render: (row) => <Badge tone={row.isActive ? 'green' : 'gray'}>{row.isActive ? 'Active' : 'Inactive'}</Badge> },
    {
      key: 'actions',
      header: '',
      className: 'text-right',
      render: (row) => (
        <Button variant="ghost" size="sm" className={row.isActive ? 'text-red-600' : ''} onClick={() => setToggling(row)}>
          {row.isActive ? 'Deactivate' : 'Activate'}
        </Button>
      ),
    },
  ];

  return (
    <>
      <PageHeader title="Customers" description="See customer data and their booking history." />

      <div className="grid gap-3 sm:grid-cols-3">
        <div className="sm:col-span-2">
          <SearchInput value={filters.search || ''} onChange={(search) => setFilters({ search })} placeholder="Search name, email or phone" />
        </div>
        <Select id="isActive" aria-label="Account status" options={ACTIVE_OPTIONS} placeholder="All accounts" value={filters.isActive || ''} onChange={(event) => setFilters({ isActive: event.target.value })} />
      </div>

      <DataTable columns={columns} rows={customers.data?.items} isLoading={customers.isLoading} error={customers.error} onRetry={customers.refetch} emptyTitle="No customers found" />
      <Pagination meta={customers.data?.meta} onPageChange={(page) => setFilters({ page })} />

      {viewingId && <CustomerDetailModal customerId={viewingId} onClose={() => setViewingId(null)} />}

      <ConfirmDialog
        isOpen={!!toggling}
        title={toggling?.isActive ? 'Deactivate customer?' : 'Activate customer?'}
        message={
          toggling?.isActive
            ? `${toggling?.name} will be logged out and cannot log in until the account is activated again.`
            : `${toggling?.name} will be able to log in and make bookings again.`
        }
        confirmLabel={toggling?.isActive ? 'Deactivate' : 'Activate'}
        variant={toggling?.isActive ? 'danger' : 'primary'}
        isLoading={toggleActive.isPending}
        onConfirm={() => toggleActive.mutate(toggling)}
        onClose={() => setToggling(null)}
      />
    </>
  );
}
