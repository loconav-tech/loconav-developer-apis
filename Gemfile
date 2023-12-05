source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "activerecord"
gem "bootsnap", require: false
gem "byebug"
gem "concurrent-ruby"
gem "lograge"
gem "logstash-event"
gem "pg"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.8"
gem "redis", "3.3.5"
gem "representable"
gem "rswag"
gem "typhoeus", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "listen", "~> 3.3"
  gem "rspec-rails", "~> 3.x"
  gem "spring"
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "web-console", ">= 4.1.0"
end

source "https://rubygems.pkg.github.com/loconav-tech" do
  gem "apollo-vt-client", "0.4.2"
  gem "loconav-request", "0.2.1"
  gem "loconav-response", "0.2.1"
  gem "log-core", "0.2.0"
  gem "meta-endpoints", "0.4.1"
end
