require 'resque/tasks'
require 'resque/server'
require 'resque/scheduler/tasks'

task 'resque:setup' => :environment do
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
