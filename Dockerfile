# Dockerfile

FROM ruby:3.4-alpine

# Install system compilation toolchain and runtime dependencies
# Alpine uses apk, which keeps the container footprint under ~80MB
RUN apk add --no-cache \
    build-base \
    pandoc \
    bash

# Set the working directory inside the container space
WORKDIR /app

# Copy the Gemfile specification to leverage Docker layer caching
COPY Gemfile* ./

# Install required Ruby automation gems (Rake, etc.)
RUN bundle install

# The container will mount local folders, so no COPY . needed for development
EXPOSE 8000

# Default command launches our raw web status dashboard and server
CMD ["bundle", "exec", "rake", "serve"]
