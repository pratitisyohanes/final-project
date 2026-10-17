const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const reportsService = require('./reports.service');

const getSummary = asyncHandler(async (req, res) => {
  const data = await reportsService.getSummary(req.query);
  success(res, { message: 'Booking summary', data });
});

const getTopServices = asyncHandler(async (req, res) => {
  const data = await reportsService.getTopServices(req.query);
  success(res, { message: 'Top services', data });
});

const getBusiestSchedules = asyncHandler(async (req, res) => {
  const data = await reportsService.getBusiestSchedules(req.query);
  success(res, { message: 'Busiest schedules', data });
});

const getRevenue = asyncHandler(async (req, res) => {
  const data = await reportsService.getRevenue(req.query);
  success(res, { message: 'Revenue report', data });
});

const exportReport = asyncHandler(async (req, res) => {
  const { filename, csv } = await reportsService.exportReport(req.query);
  res.attachment(filename).type('text/csv').send(csv);
});

module.exports = { getSummary, getTopServices, getBusiestSchedules, getRevenue, exportReport };
