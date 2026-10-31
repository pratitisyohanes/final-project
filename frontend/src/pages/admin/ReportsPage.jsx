import { useState } from 'react';
import toast from 'react-hot-toast';
import { reportsApi } from '../../api/reports.api';
import { useBusiestSchedules, useReportSummary, useRevenue, useTopServices } from '../../hooks/queries';
import { useUrlFilters, cleanParams } from '../../hooks/useUrlFilters';
import DateRangeFilter from '../../components/DateRangeFilter';
import RevenueChart from '../../components/charts/RevenueChart';
import HorizontalBarChart from '../../components/charts/HorizontalBarChart';
import StatCard from '../../components/StatCard';
import PageHeader from '../../components/ui/PageHeader';
import Card from '../../components/ui/Card';
import Button from '../../components/ui/Button';
import { Select } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { ErrorState } from '../../components/ui/States';
import { downloadBlobResponse } from '../../utils/download';
import { exportReportPdf } from '../../utils/reportPdf';
import { getErrorMessage } from '../../utils/errors';
import { formatDate, formatRupiah } from '../../utils/format';

// Without a period or range the backend reports the current month
const reportPeriods = (hasCustomRange) => [
  { value: '', label: hasCustomRange ? 'Custom range' : 'This month' },
  { value: 'this_week', label: 'This week' },
  { value: 'today', label: 'Today' },
];

const GROUP_OPTIONS = [
  { value: 'day', label: 'Per day' },
  { value: 'month', label: 'Per month' },
];

export default function ReportsPage() {
  const [filters, setFilters] = useUrlFilters({ groupBy: 'day' });
  const [downloading, setDownloading] = useState(null);

  const range = cleanParams({ period: filters.period, from: filters.from, to: filters.to });
  const summary = useReportSummary(range);
  const topServices = useTopServices({ ...range, limit: 10 });
  const busiest = useBusiestSchedules({ ...range, limit: 10 });
  const revenue = useRevenue({ ...range, groupBy: filters.groupBy });

  const exportCsv = async (type) => {
    setDownloading(type);
    try {
      const response = await reportsApi.exportCsv({ ...range, type });
      downloadBlobResponse(response, `${type}.csv`);
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setDownloading(null);
    }
  };

  const exportPdf = async () => {
    setDownloading('pdf');
    try {
      await exportReportPdf({
        summary: summary.data,
        revenue: revenue.data,
        topServices: topServices.data,
        busiest: busiest.data,
        groupBy: filters.groupBy,
      });
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setDownloading(null);
    }
  };

  if (summary.error) return <ErrorState error={summary.error} onRetry={summary.refetch} />;

  const busiestRows = (busiest.data?.byDayAndTime || []).map((row) => ({ ...row, label: `${row.dayName} ${row.startTime}` }));

  return (
    <>
      <PageHeader
        title="Reports"
        description={summary.data ? `${formatDate(summary.data.range.start)} - ${formatDate(summary.data.range.end)}` : 'Booking analytics'}
        actions={
          <>
            <Button isLoading={downloading === 'pdf'} disabled={!summary.data || !revenue.data || !topServices.data || !busiest.data} onClick={exportPdf}>
              Export PDF
            </Button>
            <Button variant="secondary" isLoading={downloading === 'bookings'} onClick={() => exportCsv('bookings')}>
              Download bookings CSV
            </Button>
            <Button variant="secondary" isLoading={downloading === 'top-services'} onClick={() => exportCsv('top-services')}>
              Download top services CSV
            </Button>
          </>
        }
      />

      <div className="rounded-xl border border-slate-200 bg-white p-4">
        <DateRangeFilter filters={filters} setFilters={setFilters} idPrefix="report" periodOptions={reportPeriods(!!(filters.from || filters.to))} />
      </div>

      {summary.isLoading ? (
        <PageLoader />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard label="Total bookings" value={summary.data.totalBookings} />
          <StatCard label="Revenue (paid)" value={formatRupiah(summary.data.totalRevenue)} />
          <StatCard label="Completed" value={summary.data.bookingsByStatus.COMPLETED} />
          <StatCard label="Cancellation rate" value={`${summary.data.cancellationRate}%`} />
        </div>
      )}

      <Card
        title="Revenue"
        actions={
          <div className="w-36">
            <Select id="groupBy" aria-label="Group revenue" options={GROUP_OPTIONS} value={filters.groupBy} onChange={(event) => setFilters({ groupBy: event.target.value })} />
          </div>
        }
      >
        {revenue.isLoading ? <PageLoader /> : <RevenueChart items={revenue.data?.items} />}
      </Card>

      <div className="grid gap-6 xl:grid-cols-2">
        <Card title="Most booked services">
          {topServices.isLoading ? <PageLoader /> : <HorizontalBarChart data={topServices.data?.items} labelKey="serviceName" valueKey="totalBookings" />}
        </Card>
        <Card title="Busiest schedules (day and time)">
          {busiest.isLoading ? <PageLoader /> : <HorizontalBarChart data={busiestRows} labelKey="label" valueKey="totalBookings" />}
        </Card>
      </div>

      <Card title="Busiest dates">
        {busiest.data?.byDate?.length ? (
          <ul className="grid gap-2 sm:grid-cols-2 lg:grid-cols-5">
            {busiest.data.byDate.map((row) => (
              <li key={row.date} className="rounded-lg bg-slate-50 px-3 py-2">
                <p className="text-sm text-slate-500">{formatDate(row.date)}</p>
                <p className="font-semibold tabular-nums text-slate-800">{row.totalBookings} bookings</p>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-slate-500">No bookings in this period.</p>
        )}
      </Card>
    </>
  );
}
