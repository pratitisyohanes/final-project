const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const paymentsService = require('./payments.service');

const markAsPaid = asyncHandler(async (req, res) => {
  const data = await paymentsService.markAsPaid(req.params.bookingId, req.body);
  success(res, { message: 'Payment recorded', data });
});

module.exports = { markAsPaid };
