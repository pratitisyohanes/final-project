const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const servicesService = require('./services.service');

const listServices = asyncHandler(async (req, res) => {
  const { items, meta } = await servicesService.listServices(req.query, req.user);
  success(res, { message: 'Service list', data: items, meta });
});

const getService = asyncHandler(async (req, res) => {
  const data = await servicesService.getServiceById(req.params.id, req.user);
  success(res, { message: 'Service detail', data });
});

const createService = asyncHandler(async (req, res) => {
  const data = await servicesService.createService(req.body);
  success(res, { statusCode: 201, message: 'Service created', data });
});

const updateService = asyncHandler(async (req, res) => {
  const data = await servicesService.updateService(req.params.id, req.body);
  success(res, { message: 'Service updated', data });
});

const deleteService = asyncHandler(async (req, res) => {
  await servicesService.deleteService(req.params.id);
  success(res, { message: 'Service deleted' });
});

module.exports = { listServices, getService, createService, updateService, deleteService };
