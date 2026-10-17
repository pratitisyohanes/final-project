const { z } = require('zod');
const { uuidParam } = require('../../utils/commonSchemas');

const markAsPaidSchema = z.object({
  params: uuidParam('bookingId'),
  body: z.object({
    method: z.enum(['CASH', 'TRANSFER', 'EWALLET']),
  }),
});

module.exports = { markAsPaidSchema };
