const { Op } = require('sequelize');
const { sequelize, Category, Service } = require('../../models');
const ApiError = require('../../utils/ApiError');
const slugify = require('../../utils/slugify');
const { getPagination, buildMeta, getSort } = require('../../utils/pagination');

// Number of non-deleted services per category
const serviceCount = [
  sequelize.literal(
    '(SELECT COUNT(*)::int FROM services s WHERE s.category_id = "Category"."id" AND s.deleted_at IS NULL)',
  ),
  'serviceCount',
];

const listCategories = async (query) => {
  const pagination = getPagination(query);
  const where = query.search ? { name: { [Op.iLike]: `%${query.search}%` } } : {};

  const { rows, count } = await Category.findAndCountAll({
    where,
    attributes: { include: [serviceCount] },
    offset: pagination.offset,
    limit: pagination.limit,
    order: getSort(query.sort, ['name', 'createdAt'], [['name', 'ASC']]),
  });

  return { items: rows, meta: buildMeta(pagination, count) };
};

const getCategoryById = async (id) => {
  const category = await Category.findByPk(id, { attributes: { include: [serviceCount] } });
  if (!category) throw ApiError.notFound('Category not found');
  return category;
};

const createCategory = ({ name }) => Category.create({ name, slug: slugify(name) });

const updateCategory = async (id, { name }) => {
  const category = await getCategoryById(id);
  return category.update({ name, slug: slugify(name) });
};

// Categories still referenced by services (including soft-deleted ones) cannot be deleted
const deleteCategory = async (id) => {
  const category = await getCategoryById(id);
  const usedBy = await Service.count({ where: { categoryId: id }, paranoid: false });
  if (usedBy > 0) throw ApiError.conflict(`Category is still used by ${usedBy} service(s)`);
  await category.destroy();
};

module.exports = { listCategories, getCategoryById, createCategory, updateCategory, deleteCategory };
