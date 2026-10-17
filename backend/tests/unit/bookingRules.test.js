const { canTransition, isBeforeCancelDeadline } = require('../../src/modules/bookings/bookings.rules');

describe('booking rules', () => {
  test('allows only valid status transitions', () => {
    expect(canTransition('PENDING', 'CONFIRMED')).toBe(true);
    expect(canTransition('CONFIRMED', 'COMPLETED')).toBe(true);
    expect(canTransition('PENDING', 'COMPLETED')).toBe(false);
    expect(canTransition('CANCELLED', 'CONFIRMED')).toBe(false);
    expect(canTransition('COMPLETED', 'CANCELLED')).toBe(false);
  });

  test('cancellation must happen at least 2 hours before the slot', () => {
    const now = new Date('2026-10-20T00:00:00Z');
    expect(isBeforeCancelDeadline(new Date('2026-10-20T03:00:00Z'), now)).toBe(true);
    expect(isBeforeCancelDeadline(new Date('2026-10-20T01:00:00Z'), now)).toBe(false);
  });
});
