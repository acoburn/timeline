all: javascript stylesheet

js: javascript

javascript:
	@echo "Compiling javascript ... \c"
	@cat ./src/config.coffee ./src/helper.coffee \
		./src/models/query.coffee \
		./src/views/prev.coffee ./src/views/next.coffee \
		./src/views/modal.coffee ./src/views/summary.coffee \
		./src/views/query_form.coffee ./src/views/message.coffee \
		./src/views/timeline.coffee \
		./src/app.coffee | ./node_modules/coffee-script/bin/coffee \
		--compile --stdio > ./js/lgbt_timeline.js
	@node_modules/uglify-js/bin/uglifyjs ./js/lgbt_timeline.js \
		--mangle --compress --screw-ie8 \
		--preamble "// (c) 2014 Amherst College. Author: Aaron Coburn <acoburn@amherst.edu>" \
		--output ./js/lgbt_timeline.min.js
	@node_modules/uglify-js/bin/uglifyjs ./js/bootstrap/modal.js \
		--mangle --compress --screw-ie8 \
		--output ./js/bootstrap.min.js
	@echo "done"

css: stylesheet

stylesheet:
	@echo "Compiling stylesheet ... \c"
	@node_modules/less/bin/lessc --compress ./less/styles.less ./css/styles.min.css
	@echo "done"



