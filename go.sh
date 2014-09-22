#!/bin/bash
node ./tiddlywiki.js ./editions/mptw --verbose --output ./mptw-out --rendertiddler $:/core/save/all index.html text/plain

[[ $1 == "publish" ]] && scp mptw-out/index.html simonb@mccabe.dreamhost.com:ts/sites/m/mp/mpt/mptw/mptw5wip.html
