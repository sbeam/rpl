# Resque tasks
require 'rake/testtask'
require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    require_relative './send_tweet'

    Resque.redis = ENV['REDIS_URL'] || 'localhost:6379'
  end

  task :scheduler_setup => :setup
end


Rake::TestTask.new do |task|
  task.libs << %w(test lib)
  task.pattern = 'test/test_*.rb'
end

task :default => :test
