FROM ruby:4.0.0-preview2

ENV BUNDLER_VERSION=2.7.2

# Use Bundler 2.x because the app and security tools depend on Bundler < 3
RUN gem install bundler:${BUNDLER_VERSION}

RUN mkdir /mfa
WORKDIR /mfa
# Install dependencies early for better layer caching
COPY Gemfile Gemfile.lock /mfa/
RUN bundle _${BUNDLER_VERSION}_ install
COPY . /mfa

EXPOSE 3404

RUN apt update && apt install -y default-mysql-client
RUN apt install -y vim
RUN apt install -y daemontools

# Start the main process.
CMD ["bundle", "_2.7.2_", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3404"]
