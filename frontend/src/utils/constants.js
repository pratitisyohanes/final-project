// Labels and badge tones mirror the enums defined in the backend models
export const BOOKING_STATUS = {
  PENDING: { label: 'Pending', tone: 'amber' },
  CONFIRMED: { label: 'Confirmed', tone: 'blue' },
  COMPLETED: { label: 'Completed', tone: 'green' },
  CANCELLED: { label: 'Cancelled', tone: 'red' },
};

export const PAYMENT_STATUS = {
  UNPAID: { label: 'Unpaid', tone: 'amber' },
  PAID: { label: 'Paid', tone: 'green' },
  REFUNDED: { label: 'Refunded', tone: 'gray' },
};

export const SCHEDULE_STATUS = {
  AVAILABLE: { label: 'Available', tone: 'green' },
  FULL: { label: 'Full', tone: 'amber' },
  CLOSED: { label: 'Closed', tone: 'gray' },
};

export const SERVICE_STATUS = {
  ACTIVE: { label: 'Active', tone: 'green' },
  INACTIVE: { label: 'Inactive', tone: 'gray' },
};

// Same transitions as bookings.rules.js on the backend
export const NEXT_BOOKING_STATUS = {
  PENDING: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['COMPLETED', 'CANCELLED'],
  COMPLETED: [],
  CANCELLED: [],
};

export const PAYMENT_METHODS = [
  { value: 'CASH', label: 'Cash' },
  { value: 'TRANSFER', label: 'Bank transfer' },
  { value: 'EWALLET', label: 'E-wallet' },
];

export const PERIOD_OPTIONS = [
  { value: '', label: 'All time' },
  { value: 'today', label: 'Today' },
  { value: 'this_week', label: 'This week' },
  { value: 'this_month', label: 'This month' },
];

export const DAYS_OF_WEEK = [
  { value: 1, label: 'Mon' },
  { value: 2, label: 'Tue' },
  { value: 3, label: 'Wed' },
  { value: 4, label: 'Thu' },
  { value: 5, label: 'Fri' },
  { value: 6, label: 'Sat' },
  { value: 7, label: 'Sun' },
];

export const toOptions = (map) => Object.entries(map).map(([value, { label }]) => ({ value, label }));

export const CANCEL_DEADLINE_HOURS = 2;
