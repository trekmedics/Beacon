# README

## Setup

### Development

Quick Guide

* bundle exec foreman start
* bundle exec rake websocket_rails:start_server

WebSocket Library

https://github.com/websocket-rails/websocket-rails/wiki/Standalone-Server-Mode

* Requires standalone server.

Prerequisites

* Ruby 2.0 or later is installed.
* The bundler gem is installed (gem install bundler).
* Git is installed.
* Redis is installed.

Environment Variables

* BEACON_TWILIO_ACCOUNT_SID
* BEACON_TWILIO_AUTH_TOKEN
* BEACON_TWILIO_PHONE_NUMBER

Steps

1. Clone repository
2. cd into local copy, then run following from within repository
3. Install/update gems (bundle)
4. Update database schema (bundle exec rake db:migrate) (Mac OS X 10.10 See Note 1 below)
5. Seed database tables (bundle exec rake db:seed) [nothing to seed script yet]
6. Run puma (bundle exec foreman start)

Test Suite

* Run unit tests:
bundle exec rake test:models RAILS_ENV=test

Install / Update Bower Components

bundle exec rake bower:install


```
#!bash

bundle
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec foreman start
```
Note 1

If installation of nokogiri fails with problems with libxml2, try
```
#!bash
brew install libxml2
bundle config build.nokogiri "--use-system-libraries --with-xml2-include=/usr/local/opt/libxml2/include/libxml2"
bundle install
```

##Redis Client

Start by running:

    redis-cli

List keys:

    > keys *

Query user's API key information

    > get user_<SID>

Manually remove user's API authentication token (will require the user to sign in with username and password again)

    > del user_<SID>


#API Update Instructions

##Command Line

Add SID to User table. From project root directory:

    bundle
    bundle exec rake db:migrate

##Rails Console

Generate SID for each user record. The SID is generated (if necessary) when the User object is initialized.

    > User.all.map(&:save)

##nginx
To check nginx.conf

    sudo /usr/sbin/nginx -t -c /etc/nginx/nginx.conf

To reload config file
    sudo /usr/sbin/nginx -s reload

To configure for Cross Origin Requests (CORS):
    /etc/nginx/nginx.conf

Below code goes in /etc/nginx/sites-available/dispatch
  which is then linked to /etc/nginx/sites-enabled/dispatch
  and is then included in /etc/nginx/nginx.conf

    # From http://enable-cors.org/server_nginx.html
    # Wide-open CORS config for nginx
    #
    location / {
       if ($request_method = 'OPTIONS') {
          add_header 'Access-Control-Allow-Origin' '*';
          #
          # Om nom nom cookies
          #
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          #
          # Custom headers and headers various browsers *should* be OK with but aren't
          #
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
          #
          # Tell client that this pre-flight info is valid for 20 days
          #
          add_header 'Access-Control-Max-Age' 1728000;
          add_header 'Content-Type' 'text/plain charset=UTF-8';
          add_header 'Content-Length' 0;
          return 204;
       }
       if ($request_method = 'POST') {
          add_header 'Access-Control-Allow-Origin' '*';
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       }
       if ($request_method = 'GET') {
          add_header 'Access-Control-Allow-Origin' '*';
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       }
       if ($request_method = 'PUT') {
          add_header 'Access-Control-Allow-Origin' '*';
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       }
       if ($request_method = 'DELETE') {
          add_header 'Access-Control-Allow-Origin' '*';
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       }
       if ($request_method = 'PATCH') {
          add_header 'Access-Control-Allow-Origin' '*';
          add_header 'Access-Control-Allow-Credentials' 'true';
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
          add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       }
    }

##Generate Documentation Pages

    bundle exec sdoc app

