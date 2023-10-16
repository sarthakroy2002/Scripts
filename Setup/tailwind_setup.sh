echo "Installation of Tailwind CSS + vite"
npm install -D tailwindcss postcss autoprefixer vite

echo "Initialization of Tailwind to the required Directory"
npx tailwindcss init -p


echo "Removing the existing tailwind Config file"
rm tailwind.config.js


echo "Configuration of Tailwind config file with Necessary changes"
echo '''/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["*"],
  theme: {
    extend: {},
  },
  plugins: [],
}
''' >> tailwind.config.js


echo "Removing Package Json script"
rm package.json

echo "Creating Package Json script with vite configuration"
echo '''{
  "name": "web-development",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "vite"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "autoprefixer": "^10.4.13",
    "postcss": "^8.4.21",
    "tailwindcss": "^3.2.4",
    "vite": "^4.1.1"
  }
}''' >> package.json


echo "Creating Style.css with tailwind configs"
echo '''@tailwind base;
@tailwind components;
@tailwind utilities;''' >> style.css


echo "Created Index HTML with style.css Linked"
echo '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>Document</title>
</head>
<body>
    <!-- Put all the Contents of Body here -->
    This is Test Page for Run build
</body>
</html>''' >> index.html

npm run start
