_s
===

Getting Started
---------------

### Installing Dependencies
1. Run `$ ./gulp.sh` in your terminal of choice from the root directory of this theme. This will install any required ruby gems and node modules.

### Update Namespace
1. Search for `'_s'` (inside single quotations) to capture the text domain.
2. Search for `_s_` to capture all the function names.
3. Search for `Text Domain: _s` in style.css.
4. Search for <code>&nbsp;_s</code> (with a space before it) to capture DocBlocks.
5. Search for `_s-` to capture prefixed handles.

OR

* Search for: `'_s'` and replace with: `'megatherium'`
* Search for: `_s_` and replace with: `megatherium_`
* Search for: `Text Domain: _s` and replace with: `Text Domain: megatherium` in style.css.
* Search for: <code>&nbsp;_s</code> and replace with: <code>&nbsp;Megatherium</code>
* Search for: `_s-` and replace with: `megatherium-`

Then, update the stylesheet header in `gulpfile.coffee` which will compile and inject itself into `style.css`

### Gulp
This theme has two modes, development and production. This was built this way to keep the gulp task processing speed to a minimum and allow one to read the files without them being minified.

#### Development
`$ gulp` of `$ gulp --env=dev`
#### Production
`$ gulp` of `$ gulp --env=prod`