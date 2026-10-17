import { BOOKING_STATUS } from '../utils/constants';
import { formatDateTime } from '../utils/format';
import { StatusBadge } from './ui/Badge';

// Status history from booking_status_logs, oldest first
export default function BookingTimeline({ logs = [] }) {
  if (!logs.length) return <p className="text-sm text-slate-500">No status history.</p>;

  return (
    <ol className="space-y-4 border-l-2 border-slate-200 pl-5">
      {logs.map((log) => (
        <li key={log.id} className="relative">
          <span className="absolute -left-[27px] top-1 h-3 w-3 rounded-full border-2 border-white bg-brand-500" />
          <div className="flex flex-wrap items-center gap-2">
            <StatusBadge status={log.toStatus} map={BOOKING_STATUS} />
            <span className="text-xs text-slate-500">{formatDateTime(log.createdAt)}</span>
          </div>
          <p className="mt-1 text-sm text-slate-600">
            {log.note || 'Status updated'}
            {log.changedBy && <span className="text-slate-400"> by {log.changedBy.name}</span>}
          </p>
        </li>
      ))}
    </ol>
  );
}
