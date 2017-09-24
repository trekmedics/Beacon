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

