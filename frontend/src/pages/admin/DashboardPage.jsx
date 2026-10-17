import { Link } from 'react-router-dom';
import { useAllBookings, useReportSummary, useRevenue } from '../../hooks/queries';
import PageHeader from '../../components/ui/PageHeader';
import Card from '../../components/ui/Card';
import StatCard from '../../components/StatCard';
import RevenueChart from '../../components/charts/RevenueChart';
import { StatusBadge } from '../../components/ui/Badge';
import { PageLoader } from '../../components/ui/Spinner';
import { ErrorState } from '../../components/ui/States';
import { BOOKING_STATUS } from '../../utils/constants';
import { formatDate, formatRupiah } from '../../utils/format';

const THIS_MONTH = { period: 'this_month' };

export default function DashboardPage() {
  const summary = useReportSummary(THIS_MONTH);
  const revenue = useRevenue({ ...THIS_MONTH, groupBy: 'day' });
  const pending = useAllBookings({ status: 'PENDING', limit: 5, sort: 'createdAt:asc' });

  if (summary.isLoading) return <PageLoader />;
  if (summary.error) return <ErrorState error={summary.error} onRetry={summary.refetch} />;

  const data = summary.data;

  return (
    <>
      <PageHeader title="Dashboard" description={`Summary for ${formatDate(data.range.start)} - ${formatDate(data.range.end)}`} />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Bookings this month" value={data.totalBookings} hint={`${data.cancellationRate}% cancelled`} />
        <StatCard label="Revenue (paid)" value={formatRupiah(data.totalRevenue)} />
        <StatCard label="Bookings scheduled today" value={data.todayBookings} />
        <StatCard label="New customers" value={data.newCustomers} />
      </div>

      <div className="grid gap-6 xl:grid-cols-3">
        <Card title="Daily revenue" className="xl:col-span-2">
          {revenue.isLoading ? <PageLoader /> : <RevenueChart items={revenue.data?.items} />}
        </Card>

        <Card title="Bookings by status">
          <ul className="space-y-3">
            {Object.entries(data.bookingsByStatus).map(([status, count]) => (
              <li key={status} className="flex items-center justify-between">
                <StatusBadge status={status} map={BOOKING_STATUS} />
                <span className="font-semibold tabular-nums text-slate-800">{count}</span>
              </li>
            ))}
          </ul>
        </Card>
      </div>

      <Card
        title="Waiting for confirmation"
        actions={
          <Link to="/admin/bookings?status=PENDING" className="text-sm font-medium text-brand-700 hover:underline">
            See all
          </Link>
        }
      >
        {pending.data?.items?.length ? (
          <ul className="divide-y divide-slate-100">
            {pending.data.items.map((booking) => (
              <li key={booking.id}>
                <Link to={`/admin/bookings/${booking.id}`} className="flex flex-col gap-1 py-3 hover:bg-slate-50 sm:flex-row sm:items-center sm:justify-between">
                  <span>
                    <span className="font-medium text-slate-800">{booking.user?.name}</span>
                    <span className="text-slate-500"> &middot; {booking.service?.name}</span>
                  </span>
                  <span className="text-sm text-slate-500">
                    {formatDate(booking.schedule?.date)} {booking.schedule?.startTime}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-slate-500">No pending bookings. Everything is up to date.</p>
        )}
      </Card>
    </>
  );
}
