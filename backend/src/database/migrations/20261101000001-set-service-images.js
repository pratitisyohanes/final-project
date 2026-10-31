const IMAGES = {
  'Coop Site Survey': 'coop-site-survey',
  'Battery Cage Installation (500 birds)': 'battery-cage-500',
  'Battery Cage Installation (1,000 birds)': 'battery-cage-1000',
  'Cage Repair & Maintenance': 'cage-repair',
  'Nipple Drinker System Setup': 'nipple-drinker',
  'Layer Vaccination Visit': 'layer-vaccination',
  'Layer Farm Consultation': 'layer-consultation',
  'Battery Cage Installation (up to 50 birds)': 'battery-cage-50',
};

// Gives existing services a cover image; services that already have one are left alone
module.exports = {
  async up(queryInterface) {
    for (const [name, file] of Object.entries(IMAGES)) {
      await queryInterface.sequelize.query('UPDATE services SET image_url = :url WHERE name = :name AND image_url IS NULL', {
        replacements: { url: `/services/${file}.svg`, name },
      });
    }
  },

  async down(queryInterface) {
    for (const file of Object.values(IMAGES)) {
      await queryInterface.sequelize.query('UPDATE services SET image_url = NULL WHERE image_url = :url', { replacements: { url: `/services/${file}.svg` } });
    }
  },
};
