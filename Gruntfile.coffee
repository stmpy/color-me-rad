module.exports = (grunt) ->
  grunt.initConfig

    coffee:
      app:
        options:
          bare: true
        expand: true
        cwd: "./coffeescript"
        src: ["*.coffee"]
        dest: "./"
        ext: ".js"

    sass:
      app:
        options:
          loadPath: "./bower_components/foundation/scss"
        files: "./style.css": ["./scss/style.scss"]

    watch:
      coffeescript:
        files: ["./coffeescript/*.coffee"]
        tasks: ["coffee:app"]
      sass:
        files: ["./scss/*.scss"]
        tasks: ["sass:app"]

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-sass"
  grunt.loadNpmTasks "grunt-notify"

  grunt.registerTask "default", "build"

  ###
  # The build process
  # (1) compile the coffee to javascript
  # (2) compile sass to css
  ###
  grunt.registerTask "build","Compile to js and css then concat and minify",["coffee","sass"]
