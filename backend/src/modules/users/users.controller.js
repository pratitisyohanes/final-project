const asyncHandler = require('../../utils/asyncHandler');
const { success } = require('../../utils/response');
const usersService = require('./users.service');

const listCustomers = asyncHandler(async (req, res) => {
  const { items, meta } = await usersService.listCustomers(req.query);
  success(res, { message: 'Customer list', data: items, meta });
});

const getCustomer = asyncHandler(async (req, res) => {
  const data = await usersService.getCustomerById(req.params.id);
  success(res, { message: 'Customer detail', data });
});

const updateCustomer = asyncHandler(async (req, res) => {
  const data = await usersService.updateCustomer(req.params.id, req.body);
  success(res, { message: 'Customer updated', data });
});

module.exports = { listCustomers, getCustomer, updateCustomer };
