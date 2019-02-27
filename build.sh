#!/bin/bash
cd crawler
cat feeds.toml | bundle exec ruby crawl.rb > ../entries.json
cd ..

cd generator
cat ../entries.json | bundle exec ruby generate.rb ../dist
cd ..

rm entries.json
