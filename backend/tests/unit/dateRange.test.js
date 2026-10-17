const { Op } = require('sequelize');
const { resolveDateRange, toDateFilter, toTimestampFilter } = require('../../src/utils/dateRange');

describe('date range utils', () => {
  test('returns null when no filter is given', () => {
    expect(resolveDateRange({})).toBeNull();
  });

  test('rejects from after to', () => {
    expect(() => resolveDateRange({ from: '2026-10-10', to: '2026-10-01' })).toThrow('Validation failed');
  });

  test('this_week starts on Monday and spans 7 days', () => {
    const { start, end } = resolveDateRange({ period: 'this_week' });
    expect(new Date(`${start}T00:00:00Z`).getUTCDay()).toBe(1);
    expect((new Date(end) - new Date(start)) / 86400000).toBe(6);
  });

  test('builds DATEONLY and WIB timestamp filters', () => {
    const range = { start: '2026-10-01', end: '2026-10-31' };
    expect(toDateFilter(range)[Op.gte]).toBe('2026-10-01');
    expect(toDateFilter(range)[Op.lte]).toBe('2026-10-31');
    expect(toTimestampFilter(range)[Op.lt].toISOString()).toBe('2026-10-31T17:00:00.000Z');
  });
});
