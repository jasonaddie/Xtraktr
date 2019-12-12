source 'https://rubygems.org'

ruby "2.3.4"

gem 'bundler'
gem "rails", "3.2.22.5"
gem "mongoid", "~> 3.1.7"

#gem 'smarter_csv' # format csv into array of hashes

gem "json"
gem "jquery-rails", '~> 3.1.0' #"~> 1.0.19"
gem 'devise', '~> 3.4.1' # user authentication
#gem 'devise-encryptable'
#gem "devise", "~> 2.0.4"
gem 'omniauth' # to login via facebook
gem 'omniauth-facebook' # to login via facebook
#gem "cancan", "~> 1.6.8" # user authorization
gem "formtastic", "~> 2.2.1" # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/mjbellantoni/formtastic-bootstrap.git", :branch => "bootstrap3_and_rails4"
#gem 'tinymce-rails', "~> 3.5.8", :branch => "tinymce-3" #tinymce editor https://github.com/spohlenz/tinymce-rails/tree/tinymce-4
gem 'tinymce-rails', "~> 4.1.10" #tinymce editor
gem 'tinymce-rails-imageupload', github: 'PerfectlyNormal/tinymce-rails-imageupload'
#gem "nested_form", "~> 0.1.1", :git => "https://github.com/davidray/nested_form.git" # easily build nested model forms with ajax links
gem 'cocoon', '~> 1.1.2' # nested forms
gem 'globalize', '~> 3.1.0' # internationalization
gem 'psych', '~> 2.0.5' # yaml parser - default psych in rails has issues
gem 'gon', '~> 5.0.4' # push data into js
gem "dynamic_form", "~> 1.1.4" # to see form error messages
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem "capistrano", "~> 2.12.0" # to deploy to server
gem "exception_notification", "~> 2.5.2" # send an email when exception occurs
gem "useragent", :git => "https://github.com/jilion/useragent.git" # browser detection
#gem "rails_autolink", "~> 1.0.9" # convert string to link if it is url
#gem 'paperclip', '~> 3.4.0' # to upload files
gem "mongoid-paperclip", :require => "mongoid_paperclip" # upload files
#gem "has_permalink", "~> 0.1.4" # create permalink slugs for nice urls
gem "kaminari", "~> 0.16.1" # paging
gem 'rails_autolink', '~> 1.1.6' # convert string url into link
gem 'spreadsheet', '~> 1.0.1' # read in spreadsheet format
gem 'roo', '~> 1.13.2' # read in spreadsheet format
gem "unidecoder", :git => "https://github.com/norman/unidecoder.git", :branch => "v2.0" #convert utf8 to ascii for permalinks
gem 'active_model_serializers', '~> 0.9.3' # easily create json serialized model data
#gem 'mongoid_search', :git => 'https://github.com/mauriciozaffari/mongoid_search.git', :branch => "master" # search mongo collections
gem 'elasticsearch-rails', '~> 0.1.9' # rails integration of elasticsearch (full text search)
gem 'elasticsearch-model', '~> 0.1.9' # rails model integration of elasticsearch (full text search)
gem 'whenever', '~> 0.9.7' # schedule cron jobs
# gem 'zipruby', '~> 0.3.6' # create zip files
# have to use this because zipruby and rubyzip use the same class names
gem "zipruby-compat", :require => 'zipruby', :git => "git@github.com:jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"
gem 'roadie', '~> 2.4.3' # apply easy styling to html emails
gem 'mongoid-slug', '~> 4.0.0' # permalink urls with mongoid
gem "autoprefixer-rails" # no need to prefix css, it will automatically do it
gem "rubyXL"
gem 'descriptive_statistics', '~> 2.4.0', :require => 'descriptive_statistics/safe'

gem 'dotenv-rails', '~> 2.7', '>= 2.7.2' # env variable management

gem 'mongoid-ancestry', '~> 0.4.2' # have parent/child relationship

gem 'recaptcha', '~> 5.2', '>= 5.2.1' # manage recaptcha on contact page

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
  gem "therubyracer"
  gem 'less-rails', git: 'git://github.com/metaskills/less-rails.git'
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'  , branch: 'bootstrap3'
  gem 'jquery-datatables-rails', '~> 3.3.0'
  gem "jquery-ui-rails" , "~> 4.1.2"
end


group :development do
  # gem 'thin' # webserver for development
 	# gem "mailcatcher", "0.5.12" # small smtp server for dev, http://mailcatcher.me/
  gem 'rb-inotify', '~> 0.9.7' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode
  gem 'exception_notification_extension', :git => 'git@github.com:JumpStartGeorgia/exception_notification_extension.git' # speed up loading page in dev mode
end

  gem 'test-unit', '~> 3.0'

group :staging, :production do
  gem 'unicorn', '~> 5.3.1' # http server
  gem 'unicorn-worker-killer', '~> 0.4.4' # kill the workers if they take up too much memory
end
