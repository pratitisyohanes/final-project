import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { bookingsApi } from '../../api/bookings.api';
import { queryKeys, useBooking } from '../../hooks/queries';
import { useApiMutation } from '../../hooks/useApiMutation';
import BookingInfo from '../../components/BookingInfo';
import Button from '../../components/ui/Button';
import Card from '../../components/ui/Card';
import { Input, Select } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { ErrorState } from '../../components/ui/States';
import { BOOKING_STATUS, NEXT_BOOKING_STATUS, PAYMENT_METHODS } from '../../utils/constants';

const ACTION_VARIANT = { CONFIRMED: 'primary', COMPLETED: 'primary', CANCELLED: 'danger' };
const ACTION_LABEL = { CONFIRMED: 'Confirm booking', COMPLETED: 'Mark as completed', CANCELLED: 'Cancel booking' };

function StatusActions({ booking }) {
  const [note, setNote] = useState('');
  const nextStatuses = NEXT_BOOKING_STATUS[booking.status];

  const updateStatus = useApiMutation((status) => bookingsApi.updateStatus(booking.id, { status, note: note.trim() || undefined }), {
    invalidate: [queryKeys.bookings, queryKeys.reports, queryKeys.schedules],
    onSuccess: () => setNote(''),
    successMessage: 'Booking status updated',
  });

  if (!nextStatuses.length) {
    return <p className="text-sm text-slate-500">This booking is {BOOKING_STATUS[booking.status].label.toLowerCase()} and can no longer change.</p>;
  }

  return (
    <div className="space-y-3">
      <Input id="status-note" label="Note (optional)" maxLength={255} value={note} onChange={(event) => setNote(event.target.value)} />
      <div className="flex flex-col gap-2">
        {nextStatuses.map((status) => (
          <Button
            key={status}
            variant={ACTION_VARIANT[status]}
            isLoading={updateStatus.isPending && updateStatus.variables === status}
            disabled={updateStatus.isPending}
            onClick={() => updateStatus.mutate(status)}
          >
            {ACTION_LABEL[status]}
          </Button>
        ))}
      </div>
    </div>
  );
}

function PaymentAction({ booking }) {
  const [method, setMethod] = useState('CASH');
  const markAsPaid = useApiMutation(() => bookingsApi.markAsPaid(booking.id, method), {
    invalidate: [queryKeys.bookings, queryKeys.reports],
    successMessage: 'Payment recorded',
  });

  return (
    <div className="space-y-3">
      <Select id="payment-method" label="Payment method" options={PAYMENT_METHODS} value={method} onChange={(event) => setMethod(event.target.value)} />
      <Button className="w-full" isLoading={markAsPaid.isPending} onClick={() => markAsPaid.mutate()}>
        Mark as paid
      </Button>
    </div>
  );
}

export default function BookingDetailPage() {
  const { id } = useParams();
  const booking = useBooking(id);

  if (booking.isLoading) return <PageLoader />;
  if (booking.error) return <ErrorState error={booking.error} onRetry={booking.refetch} />;

  const data = booking.data;
  const canRecordPayment = data.payment?.status === 'UNPAID' && data.status !== 'CANCELLED';

  return (
    <>
      <Link to="/admin/bookings" className="text-sm font-medium text-brand-700 hover:underline">
        &larr; Back to bookings
      </Link>
      <BookingInfo
        booking={data}
        showCustomer
        actions={
          <>
            <Card title="Update status">
              <StatusActions booking={data} />
            </Card>
            {canRecordPayment && (
              <Card title="Record payment">
                <PaymentAction booking={data} />
              </Card>
            )}
          </>
        }
      />
    </>
  );
}
