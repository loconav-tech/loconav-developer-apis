source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.8"
gem "puma", "~> 5.0"
gem 'typhoeus', '~> 1.2'
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "representable"
gem "rswag"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "rspec-rails", "~> 5.1.2"
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem "factory_bot_rails"
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

source "https://rubygems.pkg.github.com/loconav-tech" do
  gem "loconav-request", "0.2.1"
  gem "loconav-response", "0.2.1"
  gem "meta-endpoints", "0.4.1"
end

