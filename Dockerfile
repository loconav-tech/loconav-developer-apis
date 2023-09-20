FROM ruby:3.2.2
RUN apt-get update -qq \
  && apt-get install -y libpq-dev
WORKDIR /loconav-developer-apis
ARG BUNDLE_RUBYGEMS__PKG__GITHUB__COM
COPY Gemfile /loconav-developer-apis/Gemfile
COPY Gemfile.lock /loconav-developer-apis/Gemfile.lock
RUN bundle install
ADD . /loconav-developer-apis

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]