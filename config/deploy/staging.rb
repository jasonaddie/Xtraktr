##################################
##### SET THESE VARIABLES ########
##################################
server "beta.forset.ge", :web, :app, :db, primary: true # server where app is located
set :application, "Xtraktr" # unique name of application
set :user, "deploy" # name of user on server
set :ngnix_conf_file_loc, "staging/nginx.conf" # location of nginx conf file
set :unicorn_init_file_loc, "staging/unicorn_init.sh" # location of unicor init shell file
set :github_account_name, "ForSetGeorgia" # name of accout on git hub
set :github_repo_name, "Xtraktr" # name of git hub repo
set :git_branch_name, "flex" # name of branch to deploy
set :rails_env, "staging" # name of environment: production, staging, ...
##################################
