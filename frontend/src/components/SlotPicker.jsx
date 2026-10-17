import { useEffect, useMemo, useState } from 'react';
import { formatDate } from '../utils/format';
import { EmptyState } from './ui/States';

// Group slots by date so the customer picks a day first, then a time
const groupByDate = (slots) =>
  slots.reduce((groups, slot) => {
    (groups[slot.date] ||= []).push(slot);
    return groups;
  }, {});

export default function SlotPicker({ slots, selectedId, onSelect }) {
  const groups = useMemo(() => groupByDate(slots), [slots]);
  const dates = Object.keys(groups);
  const [activeDate, setActiveDate] = useState(dates[0]);

  useEffect(() => {
    if (!dates.includes(activeDate)) setActiveDate(dates[0]);
  }, [dates, activeDate]);

  if (!dates.length) {
    return <EmptyState title="No available slots" description="Try another week or check back later." />;
  }

  return (
    <div className="space-y-4">
      <div className="flex gap-2 overflow-x-auto pb-1" role="tablist" aria-label="Available dates">
        {dates.map((date) => (
          <button
            key={date}
            type="button"
            role="tab"
            aria-selected={date === activeDate}
            onClick={() => setActiveDate(date)}
            className={`shrink-0 rounded-lg border px-3 py-2 text-sm ${
              date === activeDate ? 'border-brand-600 bg-brand-50 font-semibold text-brand-700' : 'border-slate-200 text-slate-600 hover:border-slate-300'
            }`}
          >
            {formatDate(date, { weekday: 'short', day: 'numeric', month: 'short' })}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
        {(groups[activeDate] || []).map((slot) => (
          <button
            key={slot.id}
            type="button"
            onClick={() => onSelect(slot)}
            aria-pressed={slot.id === selectedId}
            className={`rounded-lg border px-3 py-2 text-left transition ${
              slot.id === selectedId ? 'border-brand-600 bg-brand-600 text-white' : 'border-slate-200 bg-white hover:border-brand-500'
            }`}
          >
            <span className="block text-sm font-semibold">
              {slot.startTime} - {slot.endTime}
            </span>
            <span className={`text-xs ${slot.id === selectedId ? 'text-brand-100' : 'text-slate-500'}`}>{slot.remaining} seat(s) left</span>
          </button>
        ))}
      </div>
    </div>
  );
}
