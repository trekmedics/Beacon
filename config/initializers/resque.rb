require 'resque'
require 'resque/server'
require 'resque-scheduler'
require 'resque/scheduler/server'

Resque.redis = $redis
Resque.redis.namespace = 'resque:Beacon'

Resque.schedule = YAML.load_file("#{Rails.root}/config/heartbeat_schedule.yml")
