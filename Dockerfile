FROM golang:1.18 AS building-configurator
LABEL stage=building-configurator
WORKDIR /configurator
COPY tools/app-configurator /configurator
RUN make configurator

FROM ruby:3.2.2
RUN apt-get update -qq \
  && apt-get install -y libpq-dev

WORKDIR /loconav-developer-apis
ARG BUNDLE_RUBYGEMS__PKG__GITHUB__COM
COPY Gemfile /loconav-developer-apis/Gemfile
COPY Gemfile.lock /loconav-developer-apis/Gemfile.lock
RUN bundle install
ADD . /loconav-developer-apis

COPY --from=building-configurator /configurator/target/configurator-linux /usr/bin/configurator
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY configuration.sh /usr/bin/configuration.sh
COPY generate_secrets_yml.rb /usr/bin/generate_secrets_yml.rb

RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/configuration.sh
RUN chmod +x /usr/bin/generate_secrets_yml.rb

EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
