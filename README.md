# README

* Ruby version
  * 2.4.1

* System dependencies
  * Bundler 1.16.0
  * MariaDB 10.1.23 or equivalent
  * Elasticsearch [Ubuntu instructions](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-18-04)
  * Redis [Ubuntu instructions](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04)

* Configuration
  * To install all required libraries and dependent software use the following command inside the project folder

  ```
  bundle install
  ```

  * To start in production you must first create the assets via the following command

  ```
  bundle exec rake assets:precompile
  ```

* Database creation
  * Before running the following command, ensure that the username and password is correctly entered in /config/database.rb

You will need to set some environment variables so that you can create the database.  Note that these are just for testing, you should NEVER do this in production!

Run the following from the command line:

```
export SRDRPLUS_DATABASE_USERNAME=root
export SRDRPLUS_DATABASE_PASSWORD=root
export SRDRPLUS_DATABASE_HOST=localhost
export SRDRPLUS_DATABASE_SCHEMA=srdrPLUS_development
```

  * Next run the following command inside the project folder

  ```
  bundle exec rake db:setup
  bundle exec rake team_type_tasks:AddSeedNames
  ```

* You need to set the MySql option for how GROUP BY is handled.  From the MySql command line, run the following in your database.

```
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
```

* How to run the test suite
  * To run the test suite, run the following command in the terminal

  ```
  bundle exec rails test
  ```

* Services (job queues, cache servers, search engines, etc.)
  * N/A

* Deployment instructions
  * Ensure that the database user has access to the production database defined in /config/database.rb
  * You may choose to run a small production server with Puma, which is the default rails application server. However, we recommend using Nginx or Apache HTTP Server. Please see official documentation at the official sites [here](https://nginx.org/en/docs/) and [here](https://httpd.apache.org/docs/2.4/) for installation and configuration instructions. Depending on your operating system please use the official packages to install Phusion Passenger. You can find official documentation for the Phusion Passenger project [here](https://www.phusionpassenger.com/library/deploy/nginx/deploy/ruby/).
  * Create a secret which is at least 30 characters long and consists of random numbers and letters. We will export this secret as an environment variable before starting the server. Rails can help generate this secret by running the following command

  ```
  bundle exec rails secret
  ```

  * Next we export the secret with the following command

  ```
  export SECRET_KEY_BASE=<paste the secret here>
  ```

  * To start the server we use the following command

  ```
  bundle exec rails server
  ```

  * Mail configuration can be found in /config/environment/production.rb. A sample configuration might look like the following

  ```
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.perform_caching = false

    config.action_mailer.perform_deliveries = true

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      user_name:      Rails.application.secrets.mail_username,
      password:       Rails.application.secrets.mail_password,
      domain:         'gmail.com',
      address:       'smtp.gmail.com',
      port:          '587',
      authentication: :plain,
      enable_starttls_auto: true
    }

  ```

* Generate Quality Dimension default questions
  ```
  bundle exec rails add_quality_dimensions
  ```

* Start sidekiq
  ```
  bundle exec sidekiq -q default
  ```
