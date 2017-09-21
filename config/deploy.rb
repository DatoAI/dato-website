require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)

task :production do
  set :domain, '40.74.244.164'
  set :rails_env, 'production'
  set :deploy_to, '/home/deploy/datoca'
  set :repository, 'https://github.com/DatoAI/dato-website.git'
  set :branch, 'master'
  set :user, 'deploy'       # Username in the server to SSH to.
  set :port, '22'           # SSH port number.
  set :forward_agent, true  # SSH forward_agent.
end

task :staging do
  set :domain, '13.84.150.6'
  set :rails_env, 'staging'
  set :deploy_to, '/home/deploy/datoca'
  set :repository, 'https://github.com/DatoAI/dato-website.git'
  set :branch, 'master'
  set :user, 'deploy'       # Username in the server to SSH to.
  set :port, '22'           # SSH port number.
  set :forward_agent, true  # SSH forward_agent.
end

# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('config/app.yml', 'config/database.yml')

# This task is the environment that is loaded all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'
  command %{
    echo "-----> Loading environment"
    #{echo_cmd %[. ~/.profile]}
  }
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        invoke :'puma:restart'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run :local { say 'done' }
end

namespace :puma do

  set :puma_role,      -> { fetch(:user) }
  set :puma_env,       -> { fetch(:rails_env, 'production') }
  set :puma_config,    -> { "#{fetch(:shared_path)}/config/puma.rb" }
  set :puma_socket,    -> { "#{fetch(:shared_path)}/tmp/sockets/puma.sock" }
  set :puma_state,     -> { "#{fetch(:shared_path)}/tmp/sockets/puma.state" }
  set :puma_pid,       -> { "#{fetch(:shared_path)}/tmp/pids/puma.pid" }
  set :puma_cmd,       -> { "#{fetch(:bundle_prefix)} puma" }
  set :pumactl_cmd,    -> { "#{fetch(:bundle_prefix)} pumactl" }
  set :pumactl_socket, -> { "#{fetch(:shared_path)}/tmp/sockets/pumactl.sock" }
  set :puma_stdout,    -> { "#{fetch(:shared_path)}/log/puma_access.log" }
  set :puma_stderr,    -> { "#{fetch(:shared_path)}/log/puma_error.log" }
  set :pumactl_socket, -> { "#{fetch(:shared_path)}/tmp/sockets/pumactl.sock" }

  desc 'Setup puma'
  task setup: :environment do
    command %(mkdir -p "#{fetch(:shared_path)}/tmp/sockets")
    command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/sockets")
    command %(mkdir -p "#{fetch(:shared_path)}/tmp/pids")
    command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/pids")
  end


  desc 'Start puma'
  task start: :environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        echo 'Puma is already running!';
      else
        cd #{fetch(:current_path)} && #{fetch(:puma_cmd)} -q -d -e #{fetch(:puma_env)} -b 'unix://#{fetch(:puma_socket)}' -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} --control 'unix://#{fetch(:pumactl_socket)}' --redirect-stdout #{fetch(:puma_stdout)} --redirect-stderr #{fetch(:puma_stderr)}
      fi
    ]
  end

  desc 'Stop puma'
  task stop: :environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        cd #{fetch(:current_path)} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} stop
        rm -f '#{fetch(:pumactl_socket)}'
      else
        echo 'Puma is not running!';
      fi
    ]
  end

  desc 'Restart puma'
  task restart: :environment do
    invoke :'puma:stop'
    invoke :'puma:start'
  end

  desc 'Restart puma (phased restart)'
  task phased_restart: :environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        cd #{fetch(:current_path)} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} phased-restart
      else
        echo 'Puma is not running!';
      fi
    ]
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/docs
