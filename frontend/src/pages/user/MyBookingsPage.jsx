import { Link } from 'react-router-dom';
import { useMyBookings } from '../../hooks/queries';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import PageHeader from '../../components/ui/PageHeader';
import Pagination from '../../components/ui/Pagination';
import { StatusBadge } from '../../components/ui/Badge';
import { Select } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { EmptyState, ErrorState } from '../../components/ui/States';
import { BOOKING_STATUS, PERIOD_OPTIONS } from '../../utils/constants';
import { formatDate, formatRupiah } from '../../utils/format';

const STATUS_TABS = [{ value: '', label: 'All' }, ...Object.entries(BOOKING_STATUS).map(([value, { label }]) => ({ value, label }))];

export default function MyBookingsPage() {
  const [filters, setFilters] = useUrlFilters();
  const bookings = useMyBookings({ ...filters, limit: 10 });

  return (
    <div className="space-y-6">
      <PageHeader
        title="My bookings"
        description="Track the status of every booking you made."
        actions={
          <Link to="/services" className="rounded-lg bg-brand-600 px-4 py-2 text-sm font-medium text-white hover:bg-brand-700">
            New booking
          </Link>
        }
      />

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex gap-1 overflow-x-auto rounded-lg bg-slate-100 p-1" role="tablist" aria-label="Booking status">
          {STATUS_TABS.map((tab) => (
            <button
              key={tab.value}
              type="button"
              role="tab"
              aria-selected={(filters.status || '') === tab.value}
              onClick={() => setFilters({ status: tab.value })}
              className={`shrink-0 rounded-md px-3 py-1.5 text-sm font-medium ${
                (filters.status || '') === tab.value ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
        <div className="sm:w-48">
          <Select id="period" aria-label="Schedule date" options={PERIOD_OPTIONS} value={filters.period || ''} onChange={(event) => setFilters({ period: event.target.value })} />
        </div>
      </div>

      {bookings.isLoading && <PageLoader />}
      {bookings.error && <ErrorState error={bookings.error} onRetry={bookings.refetch} />}
      {bookings.data && !bookings.data.items.length && (
        <EmptyState
          title="No bookings found"
          description="Bookings you make will appear here."
          action={
            <Link to="/services" className="text-sm font-medium text-brand-700 hover:underline">
              Browse services
            </Link>
          }
        />
      )}

      <ul className="space-y-3">
        {bookings.data?.items?.map((booking) => (
          <li key={booking.id}>
            <Link
              to={`/my-bookings/${booking.id}`}
              className="flex flex-col gap-3 rounded-xl border border-slate-200 bg-white p-4 transition hover:border-brand-500 sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="space-y-1">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-slate-900">{booking.service?.name}</span>
                  <StatusBadge status={booking.status} map={BOOKING_STATUS} />
                </div>
                <p className="text-sm text-slate-500">
                  {formatDate(booking.schedule?.date)} &middot; {booking.schedule?.startTime} - {booking.schedule?.endTime}
                </p>
                <p className="text-xs text-slate-400">{booking.bookingCode}</p>
              </div>
              <span className="font-semibold text-brand-700">{formatRupiah(booking.totalPrice)}</span>
            </Link>
          </li>
        ))}
      </ul>

      <Pagination meta={bookings.data?.meta} onPageChange={(page) => setFilters({ page })} />
    </div>
  );
}
