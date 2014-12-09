all: javascript stylesheet

js: javascript

javascript:
	@echo "Compiling javascript ... \c"
	@cat ./src/timeline.coffee | ./node_modules/coffee-script/bin/coffee --compile --stdio > ./js/lgbt_timeline.js
	@node_modules/uglify-js/bin/uglifyjs ./js/lgbt_timeline.js \
		--mangle --compress --screw-ie8 \
		--preamble "// (c) 2014 Amherst College. Author: Aaron Coburn <acoburn@amherst.edu>" \
		--output ./js/lgbt_timeline.min.js
	@echo "done"

css: stylesheet

stylesheet:
	@echo "Compiling stylesheet ... \c"
	@node_modules/less/bin/lessc --compress ./less/styles.less ./css/styles.min.css
	@echo "done"



