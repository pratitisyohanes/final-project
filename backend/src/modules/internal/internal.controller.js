const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const internalService = require('./internal.service');

const getBooking = asyncHandler(async (req, res) => {
  const data = await internalService.getBookingByCode(req.params.code);
  success(res, { message: 'Booking detail', data });
});

const settleBooking = asyncHandler(async (req, res) => {
  const data = await internalService.settleBooking(req.params.code, req.body);
  success(res, { message: 'Booking paid', data });
});

const getSummary = asyncHandler(async (req, res) => {
  const data = await internalService.getSummary(req.query);
  success(res, { message: 'Booking summary', data });
});

module.exports = { getBooking, settleBooking, getSummary };
