# create a Jekyll container from a Ruby Alpine image

# At a minimum, use Ruby 2.5 or later
FROM ruby:2.7-alpine

# Add Jekyll dependencies to Alpine
RUN apk update
RUN apk add --no-cache build-base gcc cmake git

WORKDIR /site
COPY . .

# Update the Ruby bundler and install Jekyll
RUN gem update --system
RUN gem update bundler && gem install bundler jekyll
RUN bundle install

EXPOSE 4000
