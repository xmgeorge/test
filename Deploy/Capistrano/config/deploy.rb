# Deployment Recipe
set :application, "Americash"
set :repository, "git@github.com:xmgeorge/test.git"
#
set :user, "test"
#
set :scm, :git
# # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
#
# # We set normalize_asset_timestamps to false because we don't want the
# # railties of touching the asset directories (which don't exist in our
# # application)
set :normalize_asset_timestamps, false

#Add your shared folder here

desc "After update_code, links the folders from the shared directory"
after "deploy:update_code" do
#run "ln -nfs #{shared_path}/Proxy #{release_path}/ZendApp/module/Application/src/Application/Model/Proxy"
#run "ln -nfs #{shared_path}/uploads #{release_path}/ZendApp/public/uploads"
#run "cd #{release_path}/ZendApp && php composer.phar update"
end

desc "Setups the basic folder structure for a first deployment"
after "deploy:setup" do
  # Create the default shared folders
  # config/ will store our configuration files
  # system/ will store the maintenance page (for now)
  run "mkdir -p #{shared_path}/{system,assets} #{shared_path}/log #{shared_path}/tmp #{shared_path}/Proxy #{shared_path}/uploads/resources/activity #{shared_path}/uploads/resources/organizations #{shared_path}/uploads/resources/profilepicture #{shared_path}/uploads/recipe_step_assets #{shared_path}/uploads/recipe #{shared_path}/uploads/recipe/{large_high,large_low,thumbnail_high,thumbnail_low} #{shared_path}/uploads/featured"
  run "chmod -R 777 #{shared_path}/assets"

end


# We override the default deploy task to avoid triggering deploy:restart
namespace :deploy do
  task :default do
    update_code
    symlink
  end
  
  desc "Afer every deployment, send a notification"
  after "deploy", "differences_since_last_deploy", "deploy:cleanup"
  
 # desc "Will send a notification with details on the release"
 # task :notify do
    # args = ['--pretty=format:"Commit %h by %an, %ar%n%s%n"']
    # set :extra_information, capture("cd #{current_path}; #{source.command} log #{args.join(' ')} #{previous_revision}..#{current_revision}")
  #  show.me
#    Notifier.deliver_notification_email(self)
#  end

end

namespace :show do
  desc "Show some internal Cap-Fu: What's mah NAYM?!?"
  task :me do
    set :task_name, task_call_frames.first.task.fully_qualified_name
    #puts "Running #{task_name} task"
  end
end

# Default test task
task :uname do
  run "uname -a"
end

# Default test task
namespace :conditional_deploy do
  desc "Deploys only if HEAD is newer than our last deployment"
  task :default do
    if (real_revision != current_revision)
      deploy.default
    end
  end
end

desc "Show me the differences between the last deploy and the current one"
  task :differences_since_last_deploy do
set :differences, capture("cd #{current_path}; echo \"<pre style=\"font-family: Verdana, Arial, sans serif\">\"; #{source.command} log  --pretty=format:\"%H - (%an) %s\" #{previous_revision}..#{real_revision}; echo \"</pre>\"")
#    set :differences, capture("cd #{current_path}; #{source.command} diff --name-only #{previous_revision}..#{real_revision}")
    puts "#{differences}"
  end
