gulp = require 'gulp'
sass = require 'gulp-ruby-sass'
scsslint = require 'gulp-scss-lint'
prefix = require 'gulp-autoprefixer'
watch = require 'gulp-watch'
cmq = require 'gulp-combine-media-queries'
csscomb = require 'gulp-csscomb'
compressor = require 'gulp-compressor'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
bower = require 'main-bower-files'
uglify = require 'gulp-uglify'
spritesmith = require 'gulp.spritesmith'
rimraft = require 'gulp-rimraf'
ignore = require 'gulp-ignore'
imagemin = require 'gulp-imagemin'
pngcrush = require 'imagemin-pngcrush'
plumber = require 'gulp-plumber'
livereload = require 'gulp-livereload'

onError = (err) ->
  gutil.beep()
  console.log err

# Styles
gulp.task('styles', ->
  return gulp.src('./css/scss/main.scss')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(scsslint({
      bundleExec: true
    }))
    .pipe(sass({
      sourcemap: true
      style: 'expanded'
    }))
    .pipe(gulp.dest('./css'))
    .pipe(prefix([ "last 2 versions", "> 1%", "ie 8", "ie 9"], {
      cascade: true
    }))
    .pipe(gulp.dest('./css'))
    .pipe(livereload())
)

gulp.task 'styles-compile', ->
  return gulp.src('./css/main.css')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(cmq({ log: true }))
    .pipe(csscomb())
    .pipe(compressor({
      'compress-css': true,
      'remove-intertag-spaces': true
    }))
    .pipe(gulp.dest('./css'))
    .pipe(livereload())

# Scripts
gulp.task 'scripts', ->
  return gulp.src('./js/coffee/*.coffee')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(coffee())
    .pipe(gulp.dest('./js'))
    .pipe(livereload())

# Vendors
gulp.task 'bower', ->
  return gulp.src(bower())
    .pipe(gulp.dest('./js/libs'))

gulp.task 'vendors', ['bower'], ->
  return gulp.src('./js/libs/*.js')
    .pipe(concat('plugins.js'))
#    .pipe(uglify())
    .pipe(gulp.dest('./js/'))
    .pipe(livereload())

# Images
gulp.task 'images', ->
  return gulp.src('./images/*')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(imagemin({
      progressive: true
      svgoPlugins: [{ removeViewBox: false }]
      use: [pngcrush()]
    }))
    .pipe(gulp.dest('./images/'))
    .pipe(livereload())

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
    .pipe(rimraft())

gulp.task 'default', ['build'], ->
  gulp.watch('css/scss/**/*.scss', ['styles'])
  gulp.watch('js/coffee/*.coffee', ['scripts'])
  gulp.watch('images/sprite/*.png', ['sprite'])
  gulp.watch('images/*{.jpg, .png, .svg}', ['sprite'])

gulp.task 'build', [
  'styles'
  'styles-compile'
  'vendors'
  'scripts'
  'images'
#  'sprite'
]
