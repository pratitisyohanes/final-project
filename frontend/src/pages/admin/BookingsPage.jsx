import { Link } from 'react-router-dom';
import { useAllBookings, useServices } from '../../hooks/queries';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import PageHeader from '../../components/ui/PageHeader';
import DataTable from '../../components/ui/DataTable';
import Pagination from '../../components/ui/Pagination';
import SearchInput from '../../components/ui/SearchInput';
import DateRangeFilter from '../../components/DateRangeFilter';
import { StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/FormField';
import { BOOKING_STATUS, PAYMENT_STATUS, toOptions } from '../../utils/constants';
import { formatDate, formatRupiah } from '../../utils/format';

const COLUMNS = [
  {
    key: 'bookingCode',
    header: 'Code',
    render: (row) => (
      <Link to={`/admin/bookings/${row.id}`} className="font-medium text-brand-700 hover:underline">
        {row.bookingCode}
      </Link>
    ),
  },
  { key: 'customer', header: 'Customer', render: (row) => <span className="block">{row.user?.name}<span className="block text-xs text-slate-400">{row.user?.email}</span></span> },
  { key: 'service', header: 'Service', render: (row) => row.service?.name },
  { key: 'schedule', header: 'Schedule', className: 'whitespace-nowrap', render: (row) => `${formatDate(row.schedule?.date)} ${row.schedule?.startTime}` },
  { key: 'totalPrice', header: 'Total', className: 'whitespace-nowrap', render: (row) => formatRupiah(row.totalPrice) },
  { key: 'status', header: 'Status', render: (row) => <StatusBadge status={row.status} map={BOOKING_STATUS} /> },
  { key: 'payment', header: 'Payment', render: (row) => row.payment && <StatusBadge status={row.payment.status} map={PAYMENT_STATUS} /> },
];

export default function BookingsPage() {
  const [filters, setFilters] = useUrlFilters();
  const bookings = useAllBookings({ ...filters, limit: 10 });
  const services = useServices({ limit: 100 });
  const serviceOptions = (services.data?.items || []).map((service) => ({ value: service.id, label: service.name }));

  return (
    <>
      <PageHeader title="Bookings" description="Confirm, complete or cancel customer bookings." />

      <div className="grid gap-3 rounded-xl border border-slate-200 bg-white p-4 lg:grid-cols-2">
        <SearchInput value={filters.search || ''} onChange={(search) => setFilters({ search })} placeholder="Search code, customer name or email" />
        <div className="grid grid-cols-2 gap-2">
          <Select id="status" aria-label="Status" options={toOptions(BOOKING_STATUS)} placeholder="All statuses" value={filters.status || ''} onChange={(event) => setFilters({ status: event.target.value })} />
          <Select id="serviceId" aria-label="Service" options={serviceOptions} placeholder="All services" value={filters.serviceId || ''} onChange={(event) => setFilters({ serviceId: event.target.value })} />
        </div>
        <div className="lg:col-span-2">
          <DateRangeFilter filters={filters} setFilters={setFilters} />
        </div>
      </div>

      <DataTable
        columns={COLUMNS}
        rows={bookings.data?.items}
        isLoading={bookings.isLoading}
        error={bookings.error}
        onRetry={bookings.refetch}
        emptyTitle="No bookings found"
        emptyDescription="Try changing the filters."
      />
      <Pagination meta={bookings.data?.meta} onPageChange={(page) => setFilters({ page })} />
    </>
  );
}
