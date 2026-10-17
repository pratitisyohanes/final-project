const compact = require('../../src/utils/compact');

describe('compact', () => {
  test('removes undefined but keeps null, false and 0', () => {
    expect(compact({ a: undefined, b: null, c: false, d: 0, e: 'x' })).toEqual({ b: null, c: false, d: 0, e: 'x' });
  });
});
