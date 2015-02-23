# angular-hide-on-disable

An AngularJS directive to remove properties from the model when a form control is disabled.

Please see the [home page]() for a full description of purpose and a few examples.

### Installation

Install using bower:

    bower install --save angular-hide-on-disable

Install using npm:

    npm install --save angular-hide-on-disable

### Usage

This package defines an AngularJS module named `hide-on-disable`. Since it's registered using `angular.module()` method, the script only depends on the existence of the `angular` object, and it exports nothing.

The script uses `UMD` for compatibility with AMD, CommonJS, ES6 modules, as well as global usage.

Once installed, simply use the following approach corresponding to your preferred transport.

#### Global

Add a `<script>` element after the AngularJS `<script>`:

    <script src="dist/angular-hide-on-disable.js"></script>

#### AMD


#### CommonJS

    require('angular-hide-on-disable')

#### ES6


### Registration

Finally, you'll need to add

    angular.module('myApp', ['hide-on-disable']);
