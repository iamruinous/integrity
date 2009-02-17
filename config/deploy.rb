# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com
require "eycap/recipes"

set :keep_releases, 5
set :application,   'integrity'
set :repository,    'git://github.com/copiousfreetime/integrity.git'
set :branch,        'playground'
set :user,          'jeremy'
set :password,      'VBGYjMiZ5A'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :export
set :monit_group,   "#{application}"
set :scm,           :git
set :runner,        'jeremy'
set :production_database,'integrity_playground'
set :sql_user, 'jeremy'
set :sql_pass, 'VBGYjMiZ5A'
set :sql_host, 'localhost'
set :deploy_via, :remote_cache

set :ssh_options, :keys => [ File.expand_path("~/.ssh/ey-cloud-aramis")  ]
shared_children = fetch( :shared_children ) + %w[ db builds ]
set :shared_children, shared_children.flatten

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true # required for svn+ssh:// andf git:// sometimes

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision,             lambda { source.query_revision(revision) { |cmd| capture(cmd) } }


task :playground do
  role :web, 'playground.copiousfreetime.org'
  role :app, 'playground.copiousfreetime.org'
  role :db, 'playground.copiousfreetime.org', :primary => true
  set :environment_database, Proc.new { production_database }
end

task :finalize_update, :except => { :no_release => true } do
  run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

  # mkdir -p is making sure that the directories are there for some SCM's that don't
  # save empty folders
  run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -s #{shared_path}/db #{latest_release}/db &&
      ln -s #{shared_path}/builds #{latest_release}/builds
    CMD

  if fetch(:normalize_asset_timestamps, true)
    stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
    asset_paths = %w(images stylesheets javascripts).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
    run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
  end
end


# TASKS
# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"
