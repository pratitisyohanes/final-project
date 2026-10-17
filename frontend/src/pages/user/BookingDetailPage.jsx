import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { bookingsApi } from '../../api/bookings.api';
import { queryKeys, useBooking } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import BookingInfo from '../../components/BookingInfo';
import Button from '../../components/ui/Button';
import Card from '../../components/ui/Card';
import ConfirmDialog from '../../components/ui/ConfirmDialog';
import { Textarea } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { ErrorState } from '../../components/ui/States';
import { CANCEL_DEADLINE_HOURS } from '../../utils/constants';

// Mirrors the backend rule so the button is hidden when cancelling would be rejected
const canCancel = (booking) => {
  if (!['PENDING', 'CONFIRMED'].includes(booking.status)) return false;
  const start = new Date(`${booking.schedule.date}T${booking.schedule.startTime}:00+07:00`);
  return start.getTime() - Date.now() >= CANCEL_DEADLINE_HOURS * 60 * 60 * 1000;
};

export default function BookingDetailPage() {
  const { id } = useParams();
  const booking = useBooking(id);
  const [isCancelOpen, setIsCancelOpen] = useState(false);
  const [reason, setReason] = useState('');

  const cancel = useApiMutation(() => bookingsApi.cancel(id, reason.trim() || undefined), {
    invalidate: [queryKeys.bookings, queryKeys.slots],
    successMessage: 'Booking cancelled',
    onSuccess: () => setIsCancelOpen(false),
  });

  if (booking.isLoading) return <PageLoader />;
  if (booking.error) return <ErrorState error={booking.error} onRetry={booking.refetch} />;

  const data = booking.data;

  return (
    <div className="space-y-6">
      <Link to="/my-bookings" className="text-sm font-medium text-brand-700 hover:underline">
        &larr; Back to my bookings
      </Link>

      <BookingInfo
        booking={data}
        actions={
          canCancel(data) && (
            <Card title="Need to cancel?">
              <p className="text-sm text-slate-500">You can cancel up to {CANCEL_DEADLINE_HOURS} hours before the schedule starts.</p>
              <Button variant="danger" className="mt-4 w-full" onClick={() => setIsCancelOpen(true)}>
                Cancel booking
              </Button>
            </Card>
          )
        }
      />

      <ConfirmDialog
        isOpen={isCancelOpen}
        title="Cancel this booking?"
        message="The slot will be released for other customers. This cannot be undone."
        confirmLabel="Yes, cancel"
        isLoading={cancel.isPending}
        onConfirm={() => cancel.mutate()}
        onClose={() => setIsCancelOpen(false)}
      >
        <div className="mt-4">
          <Textarea id="cancel-reason" label="Reason (optional)" maxLength={255} value={reason} onChange={(event) => setReason(event.target.value)} />
        </div>
      </ConfirmDialog>
    </div>
  );
}
