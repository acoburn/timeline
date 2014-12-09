all: javascript stylesheet

js: javascript

javascript:
	@echo -n "Compiling javascript ... "
	@node_modules/coffee-script/bin/coffee --compile --output js --join src/lgbt_timeline.coffee src/timeline.coffee
	@node_modules/uglify-js/bin/uglifyjs js/lgbt_timline.js \
		--mangle --compress --screw-ie8 \
		--preamble "// (c) 2014 Amherst College. Author: Aaron Coburn <acoburn@amherst.edu>" \
		--output js/lgbt_timeline.min.js
	@echo "done"

css: stylesheet

stylesheet:
	@echo -n "Compiling stylesheet ... "
	@node_modules/less/bin/lessc --compress less/styles.less css/styles.min.css
	@echo "done"



