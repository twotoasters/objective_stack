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
gem "mbleigh-seed-fu", :version => '1.0.0'

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

## Generators
# TODO - Generate AuthLogic shit
generate 'haml'
generate 'rspec'

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
run 'rm Rakefile'
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

## config/environments/test.rb
# Require ruby-debug inside test.rb environment
# Initialize Active Merchant inside test.rb environment

## spec/spec_helper.rb
# TODO - Lots of shit to add here...

## Helpers
# TODO - Use plugins for this shit?
# Install page_title_helper.rb
# Install JQuery helper

## Views
# Create skeleton layouts/application.html.haml

## Controllers
# TODO - Use plugins for this shit?
# Filter out password and password_confirmation in application_controller.rb

## Git Incantations
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
git :config => "git config push.default current"

# Add all files to git
git :add => '.'
if yes?('Commit changes to Git?')
  git :commit => "-a -m 'Initial commit of new Objective Stack based application...'"
end
