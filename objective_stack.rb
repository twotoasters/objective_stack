# ObjectiveStack
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
gem "activemerchant", :version => '1.4.2'
gem "mbleigh-seed-fu", :version => '1.0.0'

## Install Plugins
plugin 'active_record_tableless', :git => 'git://github.com/robinsp/active_record_tableless.git'
plugin 'custom-err-msg', :git => 'git://github.com/gumayunov/custom-err-msg.git'
plugin 'acts_as_url_param', :git => 'git://github.com/caring/acts_as_url_param.git'
plugin 'nulldb', :git => 'git://github.com/avdi/nulldb.git'
plugin 'ssl_requirement', :git => 'git://github.com/rails/ssl_requirement.git'
plugin 'rails_money', :git => 'git://github.com/jerrett/rails_money.git'

## Cleanup boilerplate messiness
# rm index.html
# rm rails.png

## Javascript
# Remove Prototype/Scriptaculous
# Install JQuery

## Initializers
# xml_mini.rb
# 00_configatron.rb

## Rakefiles
# cucumber.rake
# rcov.rake

## Rewrite Rakefile to run spec:rcov and features:rcov

## config/environments/test.rb
# Require ruby-debug inside test.rb environment
# Initialize Active Merchant inside test.rb environment

## spec/spec_helper.rb

## Helpers
# Install page_title_helper.rb

## Views
# Create skeleton layouts/application.html.haml

## Controllers
# Filter out password and password_confirmation in application_controller.rb

## Generators
# Generate AuthLogic shit
# Generate Haml plugin

## Git Incantations
# Add .gitignore in tmp/, tmp/cache, tmp/pids, tmp/sessions, and tmp/sockets
# Add .gitignore in log/
# Add .gitignore in project root
# Initialize the project
# Add all files to git
