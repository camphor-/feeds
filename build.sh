#!/bin/bash
cd crawler
bundle exec ruby crawl.rb > ../entries.json
cd ..

cd generator
cat ../entries.json | bundle exec ruby generate.rb ../dist
cd ..

rm entries.json
