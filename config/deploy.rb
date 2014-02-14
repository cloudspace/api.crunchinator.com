# config valid only for Capistrano 3.1
lock '3.1.0'

def background_rake(task)
  on roles(:app) do
    execute "cd #{release_path}; ( ( nohup bundle exec rake RAILS_ENV=#{fetch(:rails_env)} #{task} &>/dev/null ) & )"
  end
end

def foreground_rake(task)
  on roles(:app) do
    execute "cd #{release_path} && bundle exec rake RAILS_ENV=#{fetch(:rails_env)} #{task}"
  end
end

set :application, 'crunchinator'
set :repo_url, ENV['REPOSITORY_URL']

set :stages, %w(staging production)
set :default_stage, 'staging'
# require 'capistrano/ext/multistage'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/srv/www/api.crunchinator.com"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log json_data}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :ssh_options, { :keys => ['~/.ssh/id_rsa'], :forward_agent => true, :user => "root" }

namespace :deploy do
  desc "Upload environment_variables to release folder"
  task :upload_config do
    on roles(:app) do
      within release_path do
        upload!("config/environment_variables.rb", "#{release_path}/config")
      end
    end
  end

  desc "Run the seeds file"
  task(:seed) { foreground_rake("db:seed") }
end

namespace :bundler do
  desc "Run bundle install"
  task :install do
    on roles(:app) do
      within release_path do
        execute "cd #{release_path} && bundle install --binstubs --without development test"
      end
    end
  end
end

namespace :data do
  desc "Populate the queue"
  task(:populate_queue) { background_rake("api_queue:populate[local]") }

  namespace :import do
    desc "Import and process data from s3 (fast)"
    task(:s3) { background_rake("api_queue:run[20,s3]") }

    desc "Import and process data from local (fastest)"
    task(:local) { background_rake("api_queue:run[20,local]") }

    desc "Import and process data from crunchbase (slow)"
    task(:crunchbase) { background_rake("api_queue:run") }
  end

  desc "Export json to s3"
  task(:export) { foreground_rake("api_queue:upload_data") }
end

before "deploy:updated", "deploy:upload_config"
after "deploy", "bundler:install"
