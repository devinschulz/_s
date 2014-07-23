gulp = require 'gulp'
$ = require('gulp-load-plugins')()
bower = require 'main-bower-files'
spritesmith = require 'gulp.spritesmith'
ignore = require 'gulp-ignore'
pngcrush = require 'imagemin-pngcrush'
args = require('yargs').argv
path = require 'path'

# Environments
# To change environment add the --environment=production argument
DEVELOPMENT = 'development'
PRODUCTION = 'production'

config =
  environment : args.environment || DEVELOPMENT
  sass_path: 'css/sass/'
  css_path: 'css/'
  coffee_path: 'js/coffee/'
  js_path: 'js/'
  libs_path: 'js/libs/'
  images_path: 'images/'
  sass_includes: [
    'vendors/bourbon/dist/bourbon.scss'
    'vendors/neat/app/assets/stylesheets/neat.scss'
    'vendors/normalize-scss/normalize.scss'
  ]

# Prepend sass path to includes
config.sass_includes.unshift(config.sass_path)

# Prepend the CWD to each SASS include (above)
config.sass_includes = config.sass_includes.map (includePath) ->
  path.join(process.cwd(), includePath)

onError = (err) ->
  console.log err

# Styles
gulp.task('styles', ->
  return gulp.src(config.sass_path + 'main.scss')
    .pipe($.plumber({
      errorHandler: onError
    }))
    .pipe($.scssLint())
    .pipe($.rubySass({
      sourcemap: config.environment is not PRODUCTION
      trace: true
      precision: 10
      loadPath: config.sass_includes
      style: if config.environment is PRODUCTION then 'compressed' else 'expanded'
    }))
    .pipe(gulp.dest(config.css_path))
    .pipe($.pleeease({
      fallbacks:
        autoprefixer: ['last 4 versions', 'ie 8', 'ie 9', '> 5%']
      optimizers:
        minifier: if config.environment is PRODUCTION then true else false
    }))
    .pipe($.if(config.environment is PRODUCTION, $.combineMediaQueries({
      log: true
    })))
    .pipe($.if(config.environment is PRODUCTION, $.csscomb()))
    .pipe($.if(config.environment is PRODUCTION, $.compressor({
      'compress-css': true,
      'remove-intertag-spaces': true
    })))
    .pipe($.if(config.environment is PRODUCTION, $.cssshrink()))
    .pipe(gulp.dest(config.css_path))
    .pipe($.livereload())
)

# Scripts
gulp.task 'scripts', ->
  return gulp.src(config.coffee_path + '*.coffee')
    .pipe($.plumber({
      errorHandler: onError
    }))
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .pipe($.if(config.environment is PRODUCTION, $.uglify()))
    .pipe(gulp.dest(config.js_path))
    .pipe($.livereload())

# Vendors
gulp.task 'bower', ->
  return gulp.src(bower())
    .pipe(gulp.dest('./js/libs'))

gulp.task 'vendors', ['bower'], ->
  return gulp.src(config.libs_path + '*.js')
    .pipe($.concat('plugins.js'))
    .pipe($.if(config.environment is PRODUCTION, $.uglify()))
    .pipe(gulp.dest(config.js_path))
    .pipe($.livereload())

# Images
gulp.task 'images', ->
  return gulp.src(config.images_path + '/*/**/*.{jpg, png, svg}')
    .pipe($.plumber({
      errorHandler: onError
    }))
    .pipe($.imagemin({
      progressive: true
      svgoPlugins: [{ removeViewBox: false }]
      use: [pngcrush()]
    }))
    .pipe(gulp.dest(config.images_path))
    .pipe($.livereload())

gulp.task 'sprite', ['clean'], ->
  spriteData = gulp.src('./images/sprite/*.png')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(spritesmith({
      imgName: 'sprite.png'
      cssName: 'sprite.scss'
      algorithm: 'binary-tree'
      cssFormat: 'scss'
    }))
  spriteData.img.pipe(gulp.dest('./images'))
  spriteData.css.pipe(gulp.dest('./css/scss/modules'))

gulp.task 'clean', ->
  return gulp.src('./images/sprite.png', { read: false })
    .pipe($.rimraft())

gulp.task 'default', ['build'], ->
  gulp.watch('css/sass/**/*.scss', ['styles'])
  gulp.watch('js/coffee/*.coffee', ['scripts'])
  gulp.watch('images/sprite/*.png', ['sprite'])
  gulp.watch('images/*.{jpg, png, svg}', ['sprite'])

gulp.task 'build', [
  'styles'
  'vendors'
  'scripts'
  'images'
#  'sprite'
]
