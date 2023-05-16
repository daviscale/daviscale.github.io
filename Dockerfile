# create a Jekyll container from a Ruby Alpine image

# At a minimum, use Ruby 2.5 or later
FROM ruby:2.7-alpine

# Add Jekyll dependencies to Alpine
RUN apk update
RUN apk add --no-cache build-base gcc cmake git

WORKDIR /app
COPY . .

# Update the Ruby bundler and install Jekyll
RUN gem update --system
RUN gem update bundler && gem install bundler jekyll
RUN bundle install

# Run locally with
# docker run -p 4000:4000 -it -v $(pwd):/app blog sh
# and then in the container do:
# bundle exec jekyll serve --host 0.0.0.0

EXPOSE 4000
