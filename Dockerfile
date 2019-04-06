FROM ruby:2.6-alpine

WORKDIR /apps


RUN apk add --no-cache build-base libxml2-dev libxslt-dev

COPY ./Gemfile ./Gemfile.lock ./

COPY ./crawl.rb ./generate.rb ./

RUN gem install bundler
RUN bundle install --path vendor/bundle

CMD ["sh", "-c", "cat feeds.toml | bundle exec ruby crawl.rb | bundle exec ruby generate.rb > dist/feeds.json"]
