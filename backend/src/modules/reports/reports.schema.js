const { z } = require('zod');
const { dateRangeQuery } = require('../../utils/commonSchemas');

const rangeQuery = z.object({ ...dateRangeQuery });

const summarySchema = z.object({ query: rangeQuery });

const topListSchema = z.object({
  query: rangeQuery.extend({ limit: z.coerce.number().int().min(1).max(50).default(5) }),
});

const revenueSchema = z.object({
  query: rangeQuery.extend({ groupBy: z.enum(['day', 'month']).default('day') }),
});

const exportSchema = z.object({
  query: rangeQuery.extend({
    type: z.enum(['bookings', 'top-services']).default('bookings'),
    format: z.enum(['csv']).default('csv'),
  }),
});

module.exports = { summarySchema, topListSchema, revenueSchema, exportSchema };
