# Objective Stack
# A Rails template from Two Toasters
# Author: Blake Watters <blake@twotoasters.com>
# Two Toasters
# Web: http://www.twotoasters.com
# GitHub: http://github.com/twotoasters/objective_stack/tree/master

## Install Gems
# RSpec & Cucumber
gem "rspec", :lib => false, :version => "1.3.0", :env => :test
gem "rspec-rails", :lib => false, :version => "1.3.2", :env => :test
gem "cucumber", :lib => false, :version => "0.6.3", :env => :cucumber
gem "capybara", :lib => false, :version => "0.3.5", :env => :cucumber
gem 'email_spec', :version => "0.6.0", :env => :test
gem 'email_spec', :version => "0.6.0", :env => :cucumber
gem "rcov", :version => '0.9.8', :env => :test
gem 'shoulda', :version => '2.10.3', :env => :test
gem 'objective_spec', :version => '0.3.0', :env => :test
gem "factory_girl", :version => '1.2.3', :env => :test
gem 'aasm', :version => '2.1.5', :lib => 'aasm'
gem "bcrypt-ruby", :version => '2.1.2', :lib => 'bcrypt'
gem "configatron", :version => '2.5.1'
gem 'will_paginate', :version => '2.3.12'
gem 'haml', :version => '2.2.20'
gem 'validates_email_format_of', :version => '1.4.1'
gem 'nokogiri', :version => '1.4.1'
gem 'paperclip', :version => '2.3.1.1'
gem 'bullet', :version => '1.7.6'
gem 'resource_controller', :version => '0.6.6'
gem "authlogic", :version => '2.1.3'

## Install Plugins
plugin 'custom-err-msg', :git => 'git://github.com/gumayunov/custom-err-msg.git'
plugin 'acts_as_url_param', :git => 'git://github.com/caring/acts_as_url_param.git'
plugin 'nulldb', :git => 'git://github.com/Objective3/nulldb.git'
plugin 'ssl_requirement', :git => 'git://github.com/rails/ssl_requirement.git'
plugin 'rails_money', :git => 'git://github.com/jerrett/rails_money.git'
plugin 'seed-fu', :git => 'git://github.com/mbleigh/seed-fu.git'
plugin 'default_value_for', :git => 'git://github.com/FooBarWidget/default_value_for.git'

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
  run "curl -s -L http://code.jquery.com/jquery-1.4.2.min.js > jquery.min.js"
  run "curl -s -L http://code.jquery.com/jquery-1.4.2.js > jquery.js"
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

CODE

## config/environments/development.rb
append_file 'config/environments/development.rb', <<-CODE

# Initialize Bullet
config.after_initialize do
  Bullet.enable = true 
  Bullet.alert = true
  Bullet.bullet_logger = true  
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.disable_browser_cache = true
end

begin
  require 'ruby-growl'
  Bullet.growl = true
rescue MissingSourceFile
end

CODE

## Generators
# TODO - Generate AuthLogic shit
FileUtils.mkdir_p("#{root}/lib/tasks") unless File.exists?("#{root}/lib/tasks")
generate 'rspec'
generate 'cucumber --capybara'

run "haml --rails ."

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
    
    begin
      Cucumber::Rake::Task.new(:rcov) do |t|    
        t.rcov = true
        t.rcov_opts = IO.readlines("\#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
        t.rcov_opts << %[-o "coverage/features"]
      end

      RCov::VerifyTask.new('rcov:verify' => 'features:rcov') do |t| 
        t.threshold = 95.0
        t.index_html = 'coverage/features/index.html'
       end
    rescue
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

## Rewrite rspec.rake
rakefile 'rspec.rake', <<-TASK
gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9
rspec_gem_dir = nil
Dir["\#{RAILS_ROOT}/vendor/gems/*"].each do |subdir|
  rspec_gem_dir = subdir if subdir.gsub("\#{RAILS_ROOT}/vendor/gems/","") =~ /^(\w+-)?rspec-(\d+)/ && File.exist?("\#{subdir}/lib/spec/rake/spectask.rb")
end
rspec_plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec')

if rspec_gem_dir && (test ?d, rspec_plugin_dir)
  raise "\n\#{'*'*50}\nYou have rspec installed in both vendor/gems and vendor/plugins\nPlease pick one and dispose of the other.\n\#{'*'*50}\n\n"
end

if rspec_gem_dir
  $LOAD_PATH.unshift("\#{rspec_gem_dir}/lib") 
elsif File.exist?(rspec_plugin_dir)
  $LOAD_PATH.unshift("\#{rspec_plugin_dir}/lib")
end

# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

begin
  require 'spec/rake/spectask'
rescue MissingSourceFile
  module Spec
    module Rake
      class SpecTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

\#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  \#{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
\#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

Rake.application.instance_variable_get('@tasks').delete('default')

spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

task :default => :spec
task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
  t.spec_opts = ['--options', "\#{RAILS_ROOT}/spec/spec.opts"]
  t.spec_files = FileList['spec/**/*/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\#{RAILS_ROOT}/spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'coverage/specs'
    t.rcov_opts = lambda do
      IO.readlines("\#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end

  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*/*_spec.rb']
  end

  desc "Print Specdoc for all plugin examples"
  Spec::Rake::SpecTask.new(:plugin_doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['vendor/plugins/**/spec/**/*/*_spec.rb'].exclude('vendor/plugins/rspec/*')
  end

  [:models, :controllers, :views, :helpers, :lib].each do |sub|
    desc "Run the code examples in spec/\#{sub}"
    Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
      t.spec_opts = ['--options', "\#{RAILS_ROOT}/spec/spec.opts"]
      t.spec_files = FileList["spec/\#{sub}/**/*_spec.rb"]
    end
  end

  desc "Run the code examples in vendor/plugins (except RSpec's own)"
  Spec::Rake::SpecTask.new(:plugins => spec_prereq) do |t|
    t.spec_opts = ['--options', "\#{RAILS_ROOT}/spec/spec.opts"]
    t.spec_files = FileList['vendor/plugins/**/spec/**/*/*_spec.rb'].exclude('vendor/plugins/rspec/*').exclude("vendor/plugins/rspec-rails/*")
  end

  namespace :plugins do
    desc "Runs the examples for rspec_on_rails"
    Spec::Rake::SpecTask.new(:rspec_on_rails) do |t|
      t.spec_opts = ['--options', "\#{RAILS_ROOT}/spec/spec.opts"]
      t.spec_files = FileList['vendor/plugins/rspec-rails/spec/**/*/*_spec.rb']
    end
  end

  # Setup specs for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
    ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
    ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
    ::STATS_DIRECTORIES << %w(Routing\ specs spec/lib) if File.exist?('spec/routing')
    ::STATS_DIRECTORIES << %w(Integration\ specs spec/integration) if File.exist?('spec/integration')
    ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
    ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
    ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
    ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
    ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
    ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
    ::CodeStatistics::TEST_TYPES << "Integration specs" if File.exist?('spec/integration')
  end

  namespace :db do
    namespace :fixtures do
      desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y. Load from subdirectory in test/fixtures using FIXTURES_DIR=z."
      task :load => :environment do
        ActiveRecord::Base.establish_connection(Rails.env)
        base_dir = File.join(Rails.root, 'spec', 'fixtures')
        fixtures_dir = ENV['FIXTURES_DIR'] ? File.join(base_dir, ENV['FIXTURES_DIR']) : base_dir
        
        require 'active_record/fixtures'
        (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/).map {|f| File.join(fixtures_dir, f) } : Dir.glob(File.join(fixtures_dir, '*.{yml,csv}'))).each do |fixture_file|
          Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
        end
      end
    end
  end
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
--exclude "spec/*,gems/*,spec/support/*"
--rails
--sort coverage
--only-uncovered

CODE

## Generate objective_spec
generate 'objective_spec'
file 'spec/support/controller_spec_helper.rb', <<-CODE
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
  
file 'spec/support/view_spec_helper.rb', <<-CODE
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

file 'spec/support/common_spec_helper.rb', <<-CODE
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

append_file 'spec/support/shared_examples.rb', <<-CODE
# Expose a shared behaviour for disconnecting specs
share_as :Disconnected do
  include NullDB::RSpec::NullifiedDatabase
end
CODE

## spec/spec_helper.rb
run "touch spec/factories.rb"
file 'spec/spec_helper.rb', <<-CODE
# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
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

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

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

file 'spec/spec.opts', <<-CODE
--colour
--format progress
--loadby mtime
--reverse

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
