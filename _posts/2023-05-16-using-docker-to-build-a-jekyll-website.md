---
layout: post
title: "Using Docker to Build a Jekyll Website"
date: 2023-05-16 12:00:00 -0000
categories: jekyll ruby docker
---

[Jekyll](https://jekyllrb.com/) is a static site generator. Users write website content in Markdown. Then, Jekyll runs and produces static HTML and CSS. One popular use case for Jekyll is to [create blogs with GitHub Pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll).

Jekyll's [dependencies](https://jekyllrb.com/docs/) include Ruby 2.5 or higher, RubyGems, GCC, and Make. Installing those directly on the host is burdensome. Furthermore, as I mentioned in my last post, I strive to install all development dependencies in Docker containers, as it simplifies handling different versions of the same dependency. Bill Raymond offers an excellent [YouTube video](https://www.youtube.com/watch?v=owHfKAbJ6_M) and [GitHub repo](https://github.com/BillRaymond/my-jekyll-docker-website) that explain how to set up a Jekyll site via a Docker container. His tutorial relies on using VSCode's docker extension, which has some nifty features that make it easy to start a shell session on the container. The extension also automatically mounts the current host directory as a volume on the container.

I use a different text editor - [neovim](https://neovim.io/). I interact with Docker in the terminal with either `docker` or `docker-compose`. The purpose of this post is to adapt Bill Raymond's instructions for the command line. The overall approach here is to:

1. Create a docker image that includes Jekyll
2. Use the image to start a shell session on a container
3. Run a `jekyll` command to create a new site
4. Run a `jekyll` command to serve the website locally

Create a new directory for your website. This directory is called `my-site` in this example. `cd` into the directory and create `Dockerfile` and `docker-compose` files like the ones below:

Dockerfile:

```
# create a Jekyll container from a Ruby Alpine image

# Ruby 2.7 is required to support Jekyll with GitHub pages
FROM ruby:2.7-alpine

# Add Jekyll dependencies to Alpine
RUN apk update
RUN apk add --no-cache build-base gcc cmake git

WORKDIR /site
COPY . .

# Update the Ruby bundler and install Jekyll
RUN gem update --system
RUN gem update bundler && gem install bundler jekyll

# Uncomment after site is built
# RUN bundle install

EXPOSE 4000
```

docker-compose.yml:

```
services:
  my-site:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - .:/site # mount the current directory on the host system to /site on the container
    ports:
      - "4000:4000" # map port 4000 on the host to port 4000 on the container
    command: bundle exec jekyll serve --livereload --host 0.0.0.0 # used for serving the site
```

Then, run `docker-compose build`. Depending on your CPU speed, the build may take several minutes. Next run this command to start a shell session on the container:

```bash
docker-compose run --rm -it my-site sh
```

Once your shell session on the container is ready, run the commands that Bill Raymond specified in [Step 7](https://github.com/BillRaymond/my-jekyll-docker-website#step-7-build-the-jekyll-website) of his repo. After running those commands and exiting the container, you should see the Jekyll-generated files on your host system:

```
daviscale@host-system:~/my-site$ ls
404.html  Dockerfile  Gemfile  Gemfile.lock  _config.yml  _posts  about.md  docker-compose.yml  index.md
```

In the `Dockerfile`, uncomment the `RUN bundle install` line. We just installed gems during the container shell session, but that occurred in an ephemeral container. The gems should be permanently installed in the image, so rebuild it with `docker-compose build`. Finally, execute `docker-compose up` to view your new blog site locally. Visit http://localhost:4000 to view the site.
