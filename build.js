const sass     = require('node-sass')
const minify   = require('html-minifier').minify
const fs       = require('fs')
const ejs      = require('ejs')
const ncp      = require('ncp')
const rimraf   = require('rimraf')

prepareDist().then(() => {
  Promise.all([copyAssets(), buildCSS()])
    .then(([assets, css]) => {
      buildHTML(css).then(() => console.log('Built.'))
    })
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
})

function buildCSS() {
  console.log('Building CSS')
  return new Promise((resolve, reject) => {
    const css = sass.render({
      file: 'assets/sass/global.scss',
      outputStyle: 'compressed',
    }, (error, result) => {
      error ? reject(error) : resolve(result.css.toString())
    })
  })
}

function buildHTML(css) {
  console.log('Building HTML')
  return new Promise((resolve, reject) => {
    const indexTemplate = fs.readFileSync('index.ejs', 'utf8')
    const html = ejs.render(indexTemplate, {
      css : css,
    })
    const minifiedHTML = minify(html, {
      caseSensitive              : true,
      collapseWhitespace         : true,
      conservativeCollapse       : true,
      html5                      : true,
      removeAttributeQuotes      : false,
      removeComments             : true,
      removeEmptyAttributes      : true,
      removeScriptTypeAttributes : true,
      useShortDoctype            : true,
    })
    fs.writeFile('dist/index.html', minifiedHTML, (error) => {
      error ? reject(error) : resolve(html)
    })
  })
}

function prepareDist() {
  console.log('Cleaning dist')
  return new Promise((resolve, reject) => {
    rimraf('dist', (error) => {
      if (error) {
        reject(error)
        return
      }
      fs.mkdir('dist', resolve)
    })
  })
}

function copyAssets() {
  console.log('Copying assets')
  return new Promise((resolve, reject) => {
    ncp('assets/images', 'dist', (error) => {
      resolve()
    })
  })
}
