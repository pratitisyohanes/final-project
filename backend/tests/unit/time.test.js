const { addMinutes, isOverlapping, generateSlots, addDays, isoDayOfWeek, toDateTime } = require('../../src/utils/time');

describe('time utils', () => {
  test('addMinutes adds across hours', () => {
    expect(addMinutes('09:30', 90)).toBe('11:00');
  });

  test('isOverlapping detects partial overlap and ignores touching ranges', () => {
    expect(isOverlapping('09:00', '10:00', '09:30', '10:30')).toBe(true);
    expect(isOverlapping('09:00', '10:00', '10:00', '11:00')).toBe(false);
    expect(isOverlapping('09:00', '12:00', '10:00', '11:00')).toBe(true);
  });

  test('generateSlots splits an opening window by duration', () => {
    expect(generateSlots('09:00', '12:00', 60)).toEqual([
      { startTime: '09:00', endTime: '10:00' },
      { startTime: '10:00', endTime: '11:00' },
      { startTime: '11:00', endTime: '12:00' },
    ]);
    expect(generateSlots('09:00', '10:00', 90)).toEqual([]);
  });

  test('addDays and isoDayOfWeek handle month boundaries', () => {
    expect(addDays('2026-10-31', 1)).toBe('2026-11-01');
    expect(isoDayOfWeek('2026-10-11')).toBe(7);
    expect(isoDayOfWeek('2026-10-12')).toBe(1);
  });

  test('toDateTime interprets time in WIB', () => {
    expect(toDateTime('2026-10-20', '09:00').toISOString()).toBe('2026-10-20T02:00:00.000Z');
  });
});
