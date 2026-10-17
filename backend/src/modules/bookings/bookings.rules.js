// Statuses that still occupy a schedule slot
const ACTIVE_STATUSES = ['PENDING', 'CONFIRMED'];

// Booking state machine: allowed next statuses for each status
const STATUS_TRANSITIONS = {
  PENDING: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['COMPLETED', 'CANCELLED'],
  COMPLETED: [],
  CANCELLED: [],
};

const CANCEL_DEADLINE_HOURS = 2;

const canTransition = (from, to) => (STATUS_TRANSITIONS[from] || []).includes(to);

const isBeforeCancelDeadline = (slotStart, now = new Date()) =>
  slotStart.getTime() - now.getTime() >= CANCEL_DEADLINE_HOURS * 60 * 60 * 1000;

module.exports = { ACTIVE_STATUSES, STATUS_TRANSITIONS, CANCEL_DEADLINE_HOURS, canTransition, isBeforeCancelDeadline };
