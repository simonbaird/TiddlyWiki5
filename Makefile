#
# Makefile for building TiddlyWiki
# (Requires GNU make)
#

NODE_TW = node ./tiddlywiki.js

TW5_BUILD_OUTPUT = ../jermolene.github.com
#TW5_BUILD_OUTPUT = ./tw5_build_output

TW2_BUILD_OUTPUT = ./tmp/tw2

default: help

help:
	@echo "Choose from the following targets and run make <target>:"
	@echo "  test - Run test suite. (Also creates test.html in '$(TW5_BUILD_OUTPUT)')"
	@echo "  bld  - Build tiddlywiki.com in '$(TW5_BUILD_OUTPUT)'"
	@echo "  2bld - Build TiddlyWiki 2.x in '$(TW2_BUILD_OUTPUT)'"

bld: build_tw_dot_com
qbld: quick_build
2bld: build_tw2

#-----------------------------------------------------------
build_tw_dot_com: echo_output_dir output_dir clean_static cname main editions test

echo_output_dir:
	@echo Using TW5_BUILD_OUTPUT: $(TW5_BUILD_OUTPUT)

output_dir:
	mkdir -p $(TW5_BUILD_OUTPUT)

clean_static: output_dir
	rm -rf $(TW5_BUILD_OUTPUT)/static
	mkdir $(TW5_BUILD_OUTPUT)/static

cname:
	echo "tiddlywiki.com" > $(TW5_BUILD_OUTPUT)/CNAME

EDITIONS = encrypted.demo tahoelafs.demo d3demo.demo codemirrordemo.demo markdowndemo.demo highlightdemo.demo
editions: $(EDITIONS)

test: output_dir test.demo

main:
	$(NODE_TW) \
		./editions/tw5.com \
		--verbose \
		--rendertiddler $$:/core/save/all $(TW5_BUILD_OUTPUT)/index.html text/plain \
		--savetiddler $$:/favicon.ico $(TW5_BUILD_OUTPUT)/favicon.ico \
		--rendertiddler ReadMe ./readme.md text/html \
		--rendertiddler ContributingTemplate ./contributing.md text/html \
		--rendertiddler $$:/core/copyright.txt ./licenses/copyright.md text/plain \
		--rendertiddler $$:/editions/tw5.com/download-empty $(TW5_BUILD_OUTPUT)/empty.html text/plain \
		--rendertiddler $$:/editions/tw5.com/download-empty $(TW5_BUILD_OUTPUT)/empty.hta text/plain \
		--savetiddler $$:/green_favicon.ico $(TW5_BUILD_OUTPUT)/static/favicon.ico \
		--rendertiddler $$:/core/templates/static.template.html $(TW5_BUILD_OUTPUT)/static.html text/plain \
		--rendertiddler $$:/core/templates/alltiddlers.template.html $(TW5_BUILD_OUTPUT)/alltiddlers.html text/plain \
		--rendertiddler $$:/core/templates/static.template.css $(TW5_BUILD_OUTPUT)/static/static.css text/plain \
		--rendertiddlers [!is[system]] $$:/core/templates/static.tiddler.html $(TW5_BUILD_OUTPUT)/static text/plain

encrypted.demo:
	$(NODE_TW) \
		./editions/tw5.com \
		--verbose \
		--password password \
		--rendertiddler $$:/core/save/all $(TW5_BUILD_OUTPUT)/$(basename $@).html text/plain

%.demo:
	$(NODE_TW) \
		./editions/$(basename $@) \
		--verbose \
		--rendertiddler $$:/core/save/all $(TW5_BUILD_OUTPUT)/$(basename $@).html text/plain

#-----------------------------------------------------------
build_tw2: tw2_output_dir tw2_readme tw2_main tw2_compare

tw2_output_dir:
	mkdir -p $(TW2_BUILD_OUTPUT)

# Prepare the readme file from the revelant content in the tw5.com wiki
tw2_readme:
	$(NODE_TW) \
		./editions/tw5.com \
		--verbose \
		--rendertiddler TiddlyWiki2ReadMe editions/tw2/readme.md text/html

# cook the TiddlyWiki 2.x.x index file
tw2_main:
	$(NODE_TW) \
		./editions/tw2 \
		--verbose \
		--load editions/tw2/source/tiddlywiki.com/index.html.recipe \
		--rendertiddler $$:/core/templates/tiddlywiki2.template.html $(TW2_BUILD_OUTPUT)/index.html text/plain

tw2_compare:
	@diff -q $(TW2_BUILD_OUTPUT)/index.html ./editions/tw2/target/prebuilt.html || exit 0

#-----------------------------------------------------------
.PHONY: test bld 2bld qbld output_dir tw2_output_dir tw2_main tw2_readme name cname $(EDITIONS)
