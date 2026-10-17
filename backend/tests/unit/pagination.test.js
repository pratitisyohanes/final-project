const { getPagination, buildMeta, getSort } = require('../../src/utils/pagination');

describe('pagination utils', () => {
  test('uses defaults and clamps limits', () => {
    expect(getPagination({})).toEqual({ page: 1, limit: 10, offset: 0 });
    expect(getPagination({ page: '3', limit: '500' })).toEqual({ page: 3, limit: 100, offset: 200 });
  });

  test('builds meta with total pages', () => {
    expect(buildMeta({ page: 2, limit: 10 }, 47)).toEqual({ page: 2, limit: 10, total: 47, totalPages: 5 });
  });

  test('only sorts by whitelisted fields', () => {
    expect(getSort('price:desc', ['price'])).toEqual([['price', 'DESC']]);
    expect(getSort('passwordHash:asc', ['price'])).toEqual([['createdAt', 'DESC']]);
  });
});
