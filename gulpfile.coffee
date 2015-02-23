# dependencies
gulp        = require 'gulp'
less        = require 'gulp-less'
minifyCSS   = require 'gulp-minify-css'
notify      = require 'gulp-notify'
rename      = require 'gulp-rename'
imagemin    = require 'gulp-imagemin'
uglify      = require 'gulp-uglify'
gulpIf      = require 'gulp-if'
jade        = require 'gulp-jade'
umd         = require 'gulp-umd'
gutil       = require 'gulp-util'
plumber     = require 'gulp-plumber'
svgSprite   = require 'gulp-svg-sprite'
size        = require 'gulp-size'
pngcrush    = require 'imagemin-pngcrush'
del         = require 'del'
browserSync = require 'browser-sync'
browserify  = require 'browserify'
transform   = require 'vinyl-transform'


# environment shortcuts
PROD = gutil.env.prod
DEV  = !PROD


# paths
paths       = {}
paths.base  = '.'
paths.src   =
  site: "#{paths.base}/src/site"
  lib: "#{paths.base}/src/lib"
paths.dist  = "#{paths.base}/dist"
paths.bower = "#{paths.base}/bower_components"
paths.npm   = "#{paths.base}/node_modules"
paths.start = "index.html" # entry point loaded in browser


# error handling
handleError = (err) ->
  notify.onError(
    title: 'Gulp Error'
    message: "#{err.message}"
  )(err)
  @emit 'end'


# BrowserSync
gulp.task 'browser-sync', ->
  browserSync
    server:
      baseDir: paths.dist
      directory: true
    port: 2007
    startPath: paths.start


# delete entire dist folder
gulp.task 'clean', (done) ->
  del paths.dist, done


# clean 'root' task output
gulp.task 'clean:root', (done) ->
  del [
    "#{paths.dist}/CNAME"
    "#{paths.dist}/robots.txt"
    "#{paths.dist}/google07df3771ca2fed6d.html"
  ], done


# clean 'html' task output
gulp.task 'clean:html', (done) ->
  del "#{paths.dist}/*.html", done


# clean 'styles' task output
gulp.task 'clean:styles', (done) ->
  del "#{paths.dist}/styles/**/*.*", done


# clean 'scripts' task output
gulp.task 'clean:scripts', (done) ->
  del "#{paths.dist}/scripts/**/*.*", done


# clean 'lib' task output
gulp.task 'clean:lib', (done) ->
  del "#{paths.dist}/lib/**/*.*", done


# clean 'images' task output
gulp.task 'clean:images', (done) ->
  del "#{paths.dist}/images/**/*.*", done


# clean 'icons' task output
gulp.task 'clean:icons', (done) ->
  del "#{paths.dist}/icons/**/*.*", done


# copy root directory files (CNAME, robots.txt, etc.)
gulp.task 'root', ['clean:root'], ->
  gulp
    .src "#{paths.src.site}/root/**/*.*"
    .pipe gulp.dest paths.dist


# compile LESS and minify
gulp.task 'styles', ['clean:styles'], ->
  # main stylesheet
  gulp
    .src "#{paths.src.site}/styles/index.less"
    .pipe plumber handleError
    .pipe less()
    .pipe gulpIf PROD, minifyCSS()
    .pipe rename
      extname: '.min.css'
    .pipe gulp.dest "#{paths.dist}/styles"
    .pipe size()
    .pipe gulpIf DEV, browserSync.reload
      stream: true


# compile, bundle and minify scripts
#   see: https://medium.com/@sogko/gulp-browserify-the-gulp-y-way-bb359b3f9623
gulp.task 'scripts', ['clean:scripts'], ->
  # Browserify
  browserified = transform(
    (filename) ->
      browserify
        entries: filename
        extensions: ['.coffee']
        debug: true
      .bundle()
  )
  # main script
  gulp
    .src "#{paths.src.site}/scripts/index.coffee"
    .pipe plumber handleError
    .pipe browserified
    .pipe gulpIf PROD, uglify()
    .pipe rename
      extname: '.min.js'
    .pipe gulp.dest "#{paths.dist}/scripts"
    .pipe size()


# minify and wrap lib script
gulp.task 'lib', ['clean:lib'], ->
  gulp
    .src "#{paths.src.lib}/hide-on-disable.js"
    .pipe plumber handleError
    .pipe umd
      dependencies: -> ['angular']
      exports: -> 'angularHideOnDisable' # TODO: don't export anything
      namespace: -> 'angularHideOnDisable' # TODO: don't add namespace
    .pipe gulp.dest "#{paths.dist}/lib"
    .pipe size()
    .pipe uglify()
    .pipe rename
      extname: '.min.js'
    .pipe gulp.dest "#{paths.dist}/lib"
    .pipe size()


# compress images
#   see: https://github.com/sindresorhus/gulp-imagemin
gulp.task 'images', ['clean:images'], ->
  gulp
    .src "#{paths.src.site}/images/*.*"
    .pipe plumber handleError
    .pipe imagemin
      progressive: true
      svgoPlugins: [
        {
          removeViewBox: false
        }
      ]
      use: [
        pngcrush()
      ]
    .pipe gulp.dest "#{paths.dist}/images"


# SVG icon sprite
#   see: http://css-tricks.com/svg-sprites-use-better-icon-fonts/
gulp.task 'icons', ['clean:icons'], ->
  gulp
    .src "#{paths.src.site}/icons/**/*.svg"
    .pipe plumber handleError
    .pipe svgSprite
      shape:
        id:
          generator: 'icon-'
      mode:
        symbol:
          inline: true
          example: DEV and { dest: 'example/icons.html' }
          dest: 'svg'
          sprite: 'icons.svg'
    .pipe gulp.dest paths.dist


# render & copy HTML
gulp.task 'html', ['clean:html', 'icons'], ->
  gulp
    .src "#{paths.src.site}/jade/index.jade"
    .pipe plumber handleError
    .pipe jade()
    .pipe gulp.dest paths.dist


# development build & watch
gulp.task 'dev', ['root', 'html', 'styles', 'scripts', 'lib', 'images'], ->
  gulp.run 'browser-sync' # run after everything is compiled
  gulp.watch "#{paths.src.site}/styles/**/*.less", ['styles', browserSync.reload]
  gulp.watch "#{paths.src.site}/scripts/**/*.coffee", ['scripts', browserSync.reload]
  gulp.watch "#{paths.src.site}/images/**/*.*", ['images', browserSync.reload]
  gulp.watch "#{paths.src.lib}/**/*.js", ['lib', browserSync.reload]
  gulp.watch [
    "#{paths.src.site}/jade/**/*.jade"
    "#{paths.src.site}/icons/**/*.svg"
  ], ['html', browserSync.reload]


# production build
gulp.task 'prod', ['root', 'html', 'styles', 'scripts', 'lib', 'images'], ->


# build: call with 'gulp build' on command line
#   use 'gulp build --prod' to prepare assets for production use (minify, etc.)
gulp.task 'build', ['clean'], ->
  gulp.run 'prod'


# develop: call with 'gulp' on command line
gulp.task 'default', ['clean'], ->
  gulp.run 'dev'
