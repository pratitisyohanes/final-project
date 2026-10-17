/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#effaf9',
          100: '#d6f1ef',
          200: '#afe2de',
          500: '#16857f',
          600: '#0d6c67',
          700: '#0c5753',
          900: '#0b3a38',
        },
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
