import { useState } from 'react';
import { Link, useLocation, useNavigate, useParams } from 'react-router-dom';
import { bookingsApi } from '../../api/bookings.api';
import { queryKeys, useAvailableSlots, useService } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import { useAuthStore } from '../../store/authStore';
import { ServiceImage } from '../../components/ServiceCard';
import SlotPicker from '../../components/SlotPicker';
import Badge from '../../components/ui/Badge';
import Button from '../../components/ui/Button';
import Card from '../../components/ui/Card';
import { Textarea } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { ErrorState } from '../../components/ui/States';
import { addDays, formatDate, formatDuration, formatRupiah, today } from '../../utils/format';

const WINDOW_DAYS = 7;

export default function ServiceDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const user = useAuthStore((state) => state.user);

  const [weekStart, setWeekStart] = useState(today());
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [notes, setNotes] = useState('');

  const service = useService(id);
  const slots = useAvailableSlots(id, { from: weekStart, to: addDays(weekStart, WINDOW_DAYS - 1) });

  const createBooking = useApiMutation(bookingsApi.create, {
    invalidate: [queryKeys.bookings, queryKeys.slots],
    successMessage: 'Booking created. Waiting for admin confirmation.',
    onSuccess: (booking) => navigate(`/my-bookings/${booking.id}`),
  });

  const changeWeek = (direction) => {
    setSelectedSlot(null);
    setWeekStart((current) => addDays(current, direction * WINDOW_DAYS));
  };

  const handleBook = () => {
    if (!user) {
      navigate('/login', { state: { from: location } });
      return;
    }
    createBooking.mutate({ scheduleId: selectedSlot.id, notes: notes.trim() || undefined });
  };

  if (service.isLoading) return <PageLoader />;
  if (service.error) return <ErrorState error={service.error} onRetry={service.refetch} />;

  const data = service.data;
  const isAdmin = user?.role === 'ADMIN';

  return (
    <div className="space-y-6">
      <Link to="/services" className="text-sm font-medium text-brand-700 hover:underline">
        &larr; Back to services
      </Link>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="space-y-6 lg:col-span-2">
          <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
            <ServiceImage service={data} className="h-56 w-full sm:h-72" />
            <div className="space-y-3 p-6">
              {data.category && <Badge tone="blue">{data.category.name}</Badge>}
              <h1 className="text-2xl font-bold text-slate-900">{data.name}</h1>
              <div className="flex flex-wrap gap-4 text-sm text-slate-600">
                <span className="text-lg font-semibold text-brand-700">{formatRupiah(data.price)}</span>
                <span className="self-center">Duration: {formatDuration(data.durationMinutes)}</span>
              </div>
              <p className="whitespace-pre-line text-slate-600">{data.description || 'No description yet.'}</p>
            </div>
          </div>

          <Card
            title="Choose a schedule"
            actions={
              <div className="flex items-center gap-1">
                <Button variant="ghost" size="sm" disabled={weekStart <= today()} onClick={() => changeWeek(-1)} aria-label="Previous week">
                  &larr;
                </Button>
                <span className="text-xs text-slate-500">
                  {formatDate(weekStart, { day: 'numeric', month: 'short' })} - {formatDate(addDays(weekStart, WINDOW_DAYS - 1), { day: 'numeric', month: 'short' })}
                </span>
                <Button variant="ghost" size="sm" onClick={() => changeWeek(1)} aria-label="Next week">
                  &rarr;
                </Button>
              </div>
            }
          >
            {slots.isLoading && <PageLoader label="Loading schedules..." />}
            {slots.error && <ErrorState error={slots.error} onRetry={slots.refetch} />}
            {slots.data && <SlotPicker slots={slots.data.schedules} selectedId={selectedSlot?.id} onSelect={setSelectedSlot} />}
          </Card>
        </div>

        <aside className="lg:sticky lg:top-24 lg:self-start">
          <Card title="Booking summary">
            {selectedSlot ? (
              <dl className="space-y-2 text-sm">
                <div className="flex justify-between gap-4">
                  <dt className="text-slate-500">Date</dt>
                  <dd className="text-right font-medium">{formatDate(selectedSlot.date)}</dd>
                </div>
                <div className="flex justify-between gap-4">
                  <dt className="text-slate-500">Time</dt>
                  <dd className="font-medium">
                    {selectedSlot.startTime} - {selectedSlot.endTime}
                  </dd>
                </div>
                <div className="flex justify-between gap-4 border-t border-slate-100 pt-2">
                  <dt className="text-slate-500">Total</dt>
                  <dd className="font-semibold text-brand-700">{formatRupiah(data.price)}</dd>
                </div>
              </dl>
            ) : (
              <p className="text-sm text-slate-500">Select a time slot to continue.</p>
            )}

            <div className="mt-4 space-y-4">
              <Textarea id="notes" label="Notes (optional)" maxLength={500} value={notes} onChange={(event) => setNotes(event.target.value)} placeholder="Anything the staff should know" />
              {isAdmin ? (
                <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-700">Admin accounts cannot make bookings. Log in as a customer to try the flow.</p>
              ) : (
                <Button className="w-full" size="lg" disabled={!selectedSlot} isLoading={createBooking.isPending} onClick={handleBook}>
                  {user ? 'Book now' : 'Log in to book'}
                </Button>
              )}
              <p className="text-xs text-slate-500">Payment is made on site. You can cancel up to 2 hours before the schedule starts.</p>
            </div>
          </Card>
        </aside>
      </div>
    </div>
  );
}
