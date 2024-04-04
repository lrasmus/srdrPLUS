source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', '>= 5.0.8'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0', '>= 5.0.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.4'
gem 'jquery-turbolinks'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'dotenv-rails', '>= 2.7.6'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails', '>= 5.0.2'
  gem 'rspec-rails', '>= 3.8.3'
  gem "rspec_junit_formatter"
end

group :test do
  gem 'minitest-rails-capybara', '>= 3.0.2'
  gem 'simplecov', require: false
  gem 'minitest-byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', github: 'rails/web-console'
  gem 'guard'
  gem 'guard-minitest'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Annotate Models
  gem 'annotate', '~> 2.7', '>= 2.7.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


## Non-default gems.

# Use Zurb Foundation as Front-End Framework
gem 'foundation-rails', '>= 6.6.1.0'
gem 'autoprefixer-rails'
gem 'foundation-icons-sass-rails'

# Prettier templates.
gem 'slim-rails', '>= 3.3.0'

# Simplified forms.
gem 'simple_form', '>= 5.0.1'
gem 'country_select'
gem 'cocoon'

# Authentication.
gem 'devise', '>= 4.7.2'
gem 'omniauth', '>= 1.9.1'
gem 'remotipart', github: 'mshibuya/remotipart'
gem 'rails_admin', '~> 3.0.0'

# Flash messages.
gem 'toastr_rails'

# Versioning of models + soft-delete.
gem 'paper_trail', '>= 10.2.1'
gem 'paranoia', '~>2.2'

# Create lots of data.
gem 'faker', github: 'stympy/faker'

# Access ruby data in JavaScript.
gem 'gon', '>= 6.3.1'

# Pagination.
gem 'kaminari', '>= 1.2.0'

# CORS.
gem 'rack-cors'

# Help DRY up code.
gem 'responders', '>= 3.0.0'

# Api documentation.
gem 'apipie-rails', '>= 0.5.16'

# Background jobs.
gem 'sidekiq', '>= 5.2.6'

# Spreadsheet generation.
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'axlsx_rails', '>= 0.6.0'

# Searching with Elasticsearch.
gem 'searchkick'
gem 'searchjoy'

gem 'passenger', '>= 6.0.3'

# bioruby for pubmed queries.
gem 'bio'

# for parsing ris files.
gem 'ref_parsers', '~> 0.2.0'

# breadcrumbs.
gem 'breadcrumbs_on_rails'

# authorizations.
gem 'pundit'

# List reordering, Drag & Drop.
gem 'sortable-rails'

# Simple calls to external API.
gem 'httparty'

# New for Rails 5.2.
gem 'bootsnap'

# Access to AWS S3 Cloud Storage.
gem 'aws-sdk-s3', require: false

# Access Google sheets programmatically
gem 'google-api-client'

# Allows periodic background jobs
gem 'sidekiq-cron', '~> 1.2', '>= 1.2.0'

# For making sortable searchable tables
gem 'jquery-datatables'

# Formatted console logs
gem 'awesome_print'

# Fuzzy Match
gem 'fuzzy_match'

# Font Awesome Icons
#gem 'font-awesome-rails'

# Allows us to authenticate via Google's servers, so we can create google exports
gem "omniauth-google-oauth2", ">= 0.8.1"

gem "googleauth"

# Allows users to drop files to upload
gem "dropzonejs-rails", ">= 0.8.5"

# for things like cloning questions (extraction forms maybe?)
gem "amoeba"
