gulp = require 'gulp'
$ = require('gulp-load-plugins')({ camelize: true })
bower = require 'main-bower-files'
spritesmith = require 'gulp.spritesmith'
ignore = require 'gulp-ignore'
pngcrush = require 'imagemin-pngcrush'
args = require('yargs').argv
path = require 'path'
lr = require 'tiny-lr'
server = lr()

# Environments
# To change environment add the --env=prod argument
DEVELOPMENT = 'dev'
PRODUCTION = 'prod'

config =
  environment : args.env || DEVELOPMENT
  sass_path: 'assets/css/sass/'
  css_path: 'assets/css/'
  coffee_path: 'assets/js/coffee/'
  js_path: 'assets/js/'
  libs_path: 'assets/js/libs/'
  images_path: 'assets/images/'
  sass_includes: [
    'vendors/bourbon/dist/bourbon.scss'
    'vendors/neat/app/assets/stylesheets/neat.scss'
    'vendors/normalize-scss/normalize.scss'
  ],
  port: 1337

# Prepend sass path to includes
config.sass_includes.unshift config.sass_path

# Prepend the CWD to each SASS include (above)
config.sass_includes = config.sass_includes.map (includePath) ->
  path.join process.cwd(), includePath

onError = (err) ->
  $.util.beep()
  console.log err
  $.notify().write(err)

# Styles
gulp.task('styles', ->
  return gulp.src config.sass_path + 'main.scss'
    .pipe $.plumber
      errorHandler: onError
    .pipe $.scssLint()
    .pipe $.rubySass
      sourcemap: config.environment is not PRODUCTION
      trace: true
      precision: 10
      loadPath: config.sass_includes
      style: if config.environment is PRODUCTION then 'compressed' else 'expanded'
    .pipe gulp.dest config.css_path
    .pipe $.pleeease
      fallbacks:
        autoprefixer: ['last 4 versions', 'ie 8', 'ie 9', '> 5%']
      optimizers:
        minifier: if config.environment is PRODUCTION then true else false
      sourcemap: true
    .pipe $.if config.environment is PRODUCTION, $.combineMediaQueries
      log: true
    .pipe $.if config.environment is PRODUCTION, $.csscomb()
    .pipe $.if config.environment is PRODUCTION, $.compressor
      'compress-css': true,
      'remove-intertag-spaces': true
    .pipe $.if config.environment is PRODUCTION, $.cssshrink()
    .pipe gulp.dest config.css_path
    .pipe $.livereload(server)
)

# Scripts
gulp.task 'scripts', ->
  return gulp.src config.coffee_path + '*.coffee'
    .pipe $.plumber
      errorHandler: onError
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe $.if config.environment is PRODUCTION, $.uglify()
    .pipe gulp.dest config.js_path
    .pipe $.livereload(server)

gulp.task 'gulplint', ->
  return gulp.src './gulpfile.coffee'
    .pipe $.plumber
      errorHandler: onError
    .pipe $.coffeelint('./coffeelint.json')
    .pipe $.coffeelint.reporter()

# Vendors
files = [

]

gulp.task 'move', ->
  if files.length
    gulp.src files
    .pipe gulp.dest config.libs_path

gulp.task 'vendors', ['move'], ->
  return gulp.src(config.libs_path + '*.js')
  .pipe $.concat('plugins.js')
  .pipe $.if config.environment is PRODUCTION, $.uglify()
  .pipe gulp.dest config.js_path

# Images
gulp.task 'images', ->
  return gulp.src config.images_path + '/*/**/*.{jpg, png, svg}'
    .pipe $.plumber
      errorHandler: onError
    .pipe $.cache $.imagemin
      interlaced: true
      progressive: true
      svgoPlugins:
        removeViewBox: false
      use:
        pngcrush()
    .pipe gulp.dest config.images_path
    .pipe $.livereload(server)

# TODO: Fix output paths relative to images file
# TODO: Add fail-over for empty directory
gulp.task 'sprite', ['clean'], ->
  spriteData = gulp.src config.images_path + '/images/sprite/*.png'
    .pipe $.plumber
      errorHandler: onError
    .pipe $.spritesmith
      imgName: 'sprite.png'
      cssName: 'sprite.scss'
      algorithm: 'binary-tree'
      cssFormat: 'scss'
  spriteData.img.pipe gulp.dest config.images_path
  spriteData.css.pipe gulp.dest config.sass_path + '/modules'

gulp.task 'clean', ->
  return gulp.src config.images_path + '/sprite.png', { read: false }
    .pipe $.rimraf()

gulp.task 'default', ['gulplint', 'build'], ->
  server.listen config.port, (err) ->
    if err then console.log(err)
    gulp.watch config.sass_path + '/**/*.scss', ['styles']
    gulp.watch config.coffee_path + '/*.coffee', ['scripts']
    gulp.watch config.images_path + '/sprite/*.png', ['sprite']
    gulp.watch config.images_path + '/*.{jpg, png, svg}', ['sprite']

gulp.task 'build', [
  'styles'
  'vendors'
  'scripts'
  'images'
#  'sprite'
]
