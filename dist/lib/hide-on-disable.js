(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['angular'], factory);
  } else if (typeof exports === 'object') {
    module.exports = factory(require('angular'));
  } else {
    root.angularHideOnDisable = factory(root.angular);
  }
}(this, function(angular) {
// remove a property from the model and view while its form control is disabled
//   see: http://stackoverflow.com/a/28617947/167911
angular
  .module('hide-on-disable', [])
  .directive('hideOnDisable', function() {
    return {
      restrict: 'A',
      scope: {
        ngDisabled: '=',
        ngModel: '='
      },
      link: function(scope, elem, attrs) {
        var lastVal = null;
        scope.$watch('ngDisabled', function(newVal, oldVal) {
          if (newVal && !oldVal) { // if control has become disabled
            lastVal = scope.ngModel;
            scope.ngModel = undefined; // unset value
          } else if (oldVal && !newVal) { // if control has been reenabled
            if (typeof lastVal !== "undefined" && lastVal !== null) {
              scope.ngModel = lastVal; // reset value
            }
          }
        });
      }
    };
  });

return angularHideOnDisable;
}));
