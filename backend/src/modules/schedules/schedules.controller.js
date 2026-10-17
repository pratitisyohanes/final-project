const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const schedulesService = require('./schedules.service');

const listAvailableSchedules = asyncHandler(async (req, res) => {
  const data = await schedulesService.listAvailableSchedules(req.params.id, req.query);
  success(res, { message: 'Available schedules', data });
});

const listSchedules = asyncHandler(async (req, res) => {
  const { items, meta } = await schedulesService.listSchedules(req.query);
  success(res, { message: 'Schedule list', data: items, meta });
});

const getSchedule = asyncHandler(async (req, res) => {
  const data = await schedulesService.getScheduleById(req.params.id);
  success(res, { message: 'Schedule detail', data });
});

const createSchedule = asyncHandler(async (req, res) => {
  const data = await schedulesService.createSchedule(req.body);
  success(res, { statusCode: 201, message: 'Schedule created', data });
});

const bulkCreateSchedules = asyncHandler(async (req, res) => {
  const data = await schedulesService.bulkCreateSchedules(req.body);
  success(res, { statusCode: 201, message: `${data.created} schedule(s) generated`, data });
});

const updateSchedule = asyncHandler(async (req, res) => {
  const data = await schedulesService.updateSchedule(req.params.id, req.body);
  success(res, { message: 'Schedule updated', data });
});

const deleteSchedule = asyncHandler(async (req, res) => {
  await schedulesService.deleteSchedule(req.params.id);
  success(res, { message: 'Schedule deleted' });
});

module.exports = {
  listAvailableSchedules,
  listSchedules,
  getSchedule,
  createSchedule,
  bulkCreateSchedules,
  updateSchedule,
  deleteSchedule,
};
