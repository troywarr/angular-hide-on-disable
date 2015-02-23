angular = require('angular')
require('../../lib/hide-on-disable.js')

angular
  .module('example', ['hide-on-disable'])
  .controller 'ExampleController', ->
    @includePersonalInfo = true
    @formData =
      name: 'John Smith'
      dob: '01-23-1945'
      ssn: '123-456-7890'
