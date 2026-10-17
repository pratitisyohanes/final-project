import { BOOKING_STATUS, PAYMENT_METHODS, PAYMENT_STATUS } from '../utils/constants';
import { formatDate, formatDateTime, formatRupiah } from '../utils/format';
import { StatusBadge } from './ui/Badge';
import Card from './ui/Card';
import BookingTimeline from './BookingTimeline';

const methodLabel = (method) => PAYMENT_METHODS.find((item) => item.value === method)?.label || '-';

function Row({ label, children }) {
  return (
    <div className="flex justify-between gap-4 py-2">
      <dt className="text-slate-500">{label}</dt>
      <dd className="text-right font-medium text-slate-800">{children}</dd>
    </div>
  );
}

// Booking detail shared by the customer page and the admin page
export default function BookingInfo({ booking, actions, showCustomer = false }) {
  return (
    <div className="grid gap-6 lg:grid-cols-3">
      <div className="space-y-6 lg:col-span-2">
        <Card
          title={
            <span className="flex flex-wrap items-center gap-2">
              {booking.bookingCode} <StatusBadge status={booking.status} map={BOOKING_STATUS} />
            </span>
          }
        >
          <dl className="divide-y divide-slate-100 text-sm">
            <Row label="Service">{booking.service?.name}</Row>
            <Row label="Date">{formatDate(booking.schedule?.date)}</Row>
            <Row label="Time">
              {booking.schedule?.startTime} - {booking.schedule?.endTime}
            </Row>
            <Row label="Total price">{formatRupiah(booking.totalPrice)}</Row>
            <Row label="Booked at">{formatDateTime(booking.createdAt)}</Row>
            {booking.notes && <Row label="Notes">{booking.notes}</Row>}
          </dl>
        </Card>

        {showCustomer && booking.user && (
          <Card title="Customer">
            <dl className="divide-y divide-slate-100 text-sm">
              <Row label="Name">{booking.user.name}</Row>
              <Row label="Email">{booking.user.email}</Row>
              <Row label="Phone">{booking.user.phone || '-'}</Row>
            </dl>
          </Card>
        )}

        <Card title="Status history">
          <BookingTimeline logs={booking.logs} />
        </Card>
      </div>

      <div className="space-y-6">
        <Card title="Payment">
          <dl className="divide-y divide-slate-100 text-sm">
            <Row label="Status">{booking.payment ? <StatusBadge status={booking.payment.status} map={PAYMENT_STATUS} /> : '-'}</Row>
            <Row label="Amount">{booking.payment ? formatRupiah(booking.payment.amount) : '-'}</Row>
            <Row label="Method">{methodLabel(booking.payment?.method)}</Row>
            <Row label="Paid at">{formatDateTime(booking.payment?.paidAt)}</Row>
          </dl>
        </Card>
        {actions}
      </div>
    </div>
  );
}
