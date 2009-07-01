# Objective Stack
# A Rails template from Objective 3
# Author: Blake Watters <blake@objective3.com>
# Objective 3 - We build delightful apps.
# Web: http://www.objective3.com
# GitHub: http://github.com/Objective3/objective_stack/tree/master

## Install Gems
# RSpec & Cucumber
gem "rspec", :lib => false, :version => "1.2.7", :env => :test
gem "rspec-rails", :lib => false, :version => "1.2.7.1", :env => :test
gem "cucumber", :lib => false, :version => "0.3.11", :env => :test
gem "webrat", :lib => false, :version => "0.4.4", :env => :test
gem 'bmabey-email_spec', :lib => 'email_spec', :version => "0.2.0", :env => :test
gem "relevance-rcov", :lib => "rcov", :version => '0.8.3.4', :env => :test
gem "activemerchant", :lib => 'active_merchant', :version => '1.4.2'
gem "mbleigh-seed-fu", :version => '1.0.0', :lib => false
gem 'rubyist-aasm', :version => '2.0.5', :source => "http://gems.github.com", :lib => 'aasm'
gem "bcrypt-ruby", :version => '2.0.5', :lib => 'bcrypt'
gem "configatron", :version => '2.3.2'
gem "authlogic", :version => '2.1.0'
gem "thoughtbot-factory_girl", :version => '1.2.1', :lib => "factory_girl", :source => "http://gems.github.com"
gem 'mislav-will_paginate', :version => '2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'haml', :version => '2.0.9'
gem 'giraffesoft-resource_controller', :version => "0.6.5", :source => 'http://gems.github.com', :lib => 'resource_controller'
gem 'alexdunae-validates_email_format_of', :version => '1.4', :lib => 'validates_email_format_of'
gem 'nokogiri', :version => '1.3.2'
gem 'paperclip', :version => '2.1.2'

## Install Plugins
plugin 'active_record_tableless', :git => 'git://github.com/robinsp/active_record_tableless.git'
plugin 'custom-err-msg', :git => 'git://github.com/gumayunov/custom-err-msg.git'
plugin 'acts_as_url_param', :git => 'git://github.com/caring/acts_as_url_param.git'
plugin 'nulldb', :git => 'git://github.com/avdi/nulldb.git'
plugin 'ssl_requirement', :git => 'git://github.com/rails/ssl_requirement.git'
plugin 'rails_money', :git => 'git://github.com/jerrett/rails_money.git'

## Cleanup boilerplate messiness
run 'rm public/index.html'
run 'rm public/images/rails.png'

## Javascript
# Remove Prototype/Scriptaculous
inside('public/javascripts/') do
  run 'rm controls.js'
  run 'rm dragdrop.js'
  run 'rm effects.js'
  run 'rm prototype.js'
  # Install JQuery
  run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > jquery.min.js"
  run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.js > jquery.js"
end

## Initializers
# xml_mini.rb
initializer 'xml_mini.rb', <<-CODE
# Set XmlMini backend to Nokogiri
ActiveSupport::XmlMini.backend = 'Nokogiri'
CODE
# 00_configatron.rb
initializer '00_configatron.rb', <<-CODE
# Set global configatron options here
# For more info see: http://github.com/markbates/configatron/tree/master
# configatron.some_setting = 'some_value'
CODE

## Install Gems
rake 'gems:install', :sudo => true

## config/environments/test.rb
append_file 'config/environments/test.rb', <<-CODE

require 'ruby-debug'

# Initialize Active Merchant
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
end

CODE

## Generators
# TODO - Generate AuthLogic shit
FileUtils.mkdir_p("#{root}/lib/tasks") unless File.exists?("#{root}/lib/tasks")
generate 'haml'
generate 'rspec'
generate 'cucumber'

## Rakefiles
# cucumber.rake
rakefile 'cucumber.rake', <<-TASK
$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

begin
  require 'cucumber/rake/task'
  require 'spec/rake/verify_rcov'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty"
  end
  task :features => 'db:test:prepare'

  namespace :features do
    Cucumber::Rake::Task.new(:all) do |t|
      t.cucumber_opts = "--format pretty"
    end

    Cucumber::Rake::Task.new(:rcov) do |t|    
      t.rcov = true
      t.rcov_opts = IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
      t.rcov_opts << %[-o "coverage/features"]
    end

    RCov::VerifyTask.new('rcov:verify' => 'features:rcov') do |t| 
      t.threshold = 95.0
      t.index_html = 'coverage/features/index.html'
     end
   end
rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end

TASK
# rcov.rake
rakefile 'rcov.rake', <<-TASK
begin
  require 'spec/rake/spectask'
  require 'spec/rake/verify_rcov'

  RCov::VerifyTask.new('spec:rcov:verify' => 'spec:rcov') do |t| 
    t.threshold = 95.0
    t.index_html = 'coverage/specs/index.html'
    t.require_exact_threshold = false
  end
rescue LoadError
  task 'spec:rcov:verify' do
    puts "Failure!"
  end
end

TASK

## Rewrite Rakefile to run spec:rcov and features:rcov
file 'Rakefile', <<-CODE
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# Remove the default rake task so we can cleanly add RCov enforcement
Rake.application.remove_task(:default)

# Run the Cucumber Features after full test run
task :default => ['spec:rcov:verify', 'features:rcov:verify']

CODE

# rcov.opts
file 'spec/rcov.opts', <<-CODE
--exclude "spec/*,gems/*,features/*" 
--rails
--sort coverage
--only-uncovered

CODE

## Generate objective_spec
generate 'objective_spec'
file 'spec/spec_helpers/controller.rb', <<-CODE
module ControllerSpecHelper
  
  def enable_ssl
    request.env['HTTPS'] = 'on'
  end
  
  def disable_ssl
    request.env['HTTPS'] = 'off'
  end
  
  def with_ssl
    old_https = @request.env['HTTPS']
    begin
      request.env['HTTPS'] = 'on'
      yield
    ensure
      request.env['HTTPS'] = old_https
    end
  end
  
end

CODE
  
file 'spec/spec_helpers/view.rb', <<-CODE
module ViewSpecHelper
  
  def page_title
    assigns[:content_for_page_title]
  end
  
  def stub_authentication_logged_in!
    template.stub!(:logged_in?).and_return(true)
    activate_authlogic
    @user = Factory(:user)
    UserSession.create(@user)
    template.stub!(:current_user).and_return(@user)
  end
  
  # Authenticate the Spec harness
  def stub_current_user!
    @user = Factory.build(:user, :admin => false)
    template.stub!(:current_user).and_return(@user)
    @user
  end
  
  def stub_admin_user!
    @user = Factory.build(:user, :admin => true)
    template.stub!(:current_user).and_return(@user)
    @user    
  end
  
  def content_for(name)
    response.template.instance_variable_get("@content_for_\#{name}")
  end
  
end
CODE

file 'spec/spec_helpers/common.rb', <<-CODE
module CommonSpecHelper
  
  def will_paginate_collection(*collection)
    WillPaginate::Collection.create(1, 10, collection.size) do |pager|
      pager.replace(collection.flatten)
    end
  end
  
  def whitelisted_mock_classes
    [Paperclip::Attachment]
  end
  
  def mock_model(model_class, options_and_stubs = {}, &block)
    if whitelisted_mock_classes.include?(model_class)
      super
    else
      raise "mock_model is not allowed for \#{model_class} objects! Use a Factory!"
    end
  end
  
  def stub_model(model_class, stubs={})
    if whitelisted_mock_classes.include?(model_class)
      super
    else
      raise "stub_model is not allowed for \#{model_class} objects! Use a Factory!"
    end
  end
  
  def save_response(path = "\#{RAILS_ROOT}/response.body")
    puts "Saving response body to \#{path}"
    File.open(path, 'w+') {|f| f << response.body}
  end
  
end
CODE

## spec/spec_helper.rb
run "touch spec/factories.rb"
file 'spec/spec_helper.rb', <<-CODE
# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

# Load the Objective Spec framework
require 'objective_spec'

# Load additional helpers
require 'authlogic/test_case'
require 'factory_girl'
require 'nokogiri'
require 'nulldb_rspec'

# Load the Factory Girl global factories
require File.join(Rails.root, 'spec', 'factories')

# Load up the Email Spec helpers
require "email_spec/helpers"
require "email_spec/matchers"

# Expose a shared behaviour for disconnecting specs
unless defined?(Disconnected)
  share_as :Disconnected do
    include NullDB::RSpec::NullifiedDatabase
  end
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  config.include(Authlogic::TestCase)
  
  # Work around problem with generated spec's being annoyed at the URL Rewriter...
  config.include(ActionController::UrlWriter, :type => :view)
  config.include(ViewSpecHelper, :type => :view)
  config.include(ControllerSpecHelper, :type => :controller)
  
  # TODO - Encapsulate into objective_spec/mailer.rb
  config.include(EmailSpec::Helpers, :type => :mailer)
  config.include(EmailSpec::Matchers, :type => :mailer)
  config.include(ActionController::UrlWriter, :type => :mailer)
  
  # Disconnect all specs except for Model and Controller
  config.include(Disconnected, :type => :helper)
  config.include(Disconnected, :type => :mailer)
  config.include(Disconnected, :type => :view)
  
  config.include(CommonSpecHelper)  
end
CODE

## Helpers
# TODO - Use plugins for this shit?
# Install page_title_helper.rb
# Install JQuery helper

## Views
# Create skeleton layouts/application.html.haml

## Controllers
file 'app/controllers/application_controller.rb', <<-END
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :card_number, :card_verification
end

END

## Git Incantations
inside('coverage/specs') do
  run "echo '*' > .gitignore"
end
inside('coverage/features') do
  run "echo '*' > .gitignore"
end
run "touch tmp/.gitignore tmp/cache/.gitignore tmp/pids/.gitignore"
run "touch tmp/sessions/.gitignore tmp/sockets/.gitignore log/.gitignore vendor/.gitignore"
file '.gitignore', <<-END
.DS_Store
tmp/*
vendor/rails*
config/database.yml
log/*
*.tmproj
coverage
design
config/*.sphinx.conf
db/sphinx
doc/api
doc/app
doc/*(Autosaved)
db/*.sqlite3
public/attachments/*
public/system
END

# Initialize the project
unless File.exists?("#{root}/.git")
  git :init
end

# Configure Git
git :config => "branch.master.remote 'origin'"
git :config => "branch.master.merge 'refs/heads/master'"
git :config => "push.default current"

# Add all files to git
git :add => '.'
if yes?('Commit changes to Git? (y/n)')
  git :commit => "-a -m 'Initial commit of new Objective Stack based application...'"
end
