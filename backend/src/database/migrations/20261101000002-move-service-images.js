// /services is also the app route, so a /services/ image folder made nginx answer 403; images now live in /service-images/
module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query("UPDATE services SET image_url = REPLACE(image_url, '/services/', '/service-images/') WHERE image_url LIKE '/services/%'");
  },

  async down(queryInterface) {
    await queryInterface.sequelize.query("UPDATE services SET image_url = REPLACE(image_url, '/service-images/', '/services/') WHERE image_url LIKE '/service-images/%'");
  },
};
