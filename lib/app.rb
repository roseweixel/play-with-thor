require 'thor'
require 'fileutils'
require 'pry'
require 'active_support/core_ext/string'

class CLI < Thor

  package_name "App"
  map "l" => :list

  # just to test/experiment with commands
  desc "list [SEARCH]", "show a list of things"
  def list(search="")
    puts "List #{search}"
  end

  desc "make_sinatra_skeleton", "generate the skeleton of a new Sinatra app"
  option :ar, :type => :boolean, :default => true
  # Pass in an empty string to avoid ArgumentError
  def make_sinatra_skeleton(name="", *resources)
    if name == ""
      puts "You must specify a name for your new Sinatra app."
    else
      ## Make top level directories
      # Does not make another one if exists
      make_directory "#{name}/app"
      make_directory "#{name}/app/models"
      make_directory "#{name}/app/controllers"
      make_directory "#{name}/app/views"
      make_directory "#{name}/config"
      
      ## Make standard files
      # generate environment.rb
      environment = File.new("#{name}/config/environment.rb", 'w')
      environment << environment_contents(options[:ar])

      # generate config.ru
      config = File.new("#{name}/config.ru", 'w')
      config << config_ru_contents(options[:ar])

      # generate application_controller.rb
      application_controller = File.new("#{name}/app/controllers/application_controller.rb", 'w')
      application_controller << "class ApplicationController < Sinatra::Base\nend"
      
      # generate Gemfile
      gemfile = File.new("#{name}/Gemfile", 'w')
      gemfile << gemfile_contents(options[:ar])

      # generate models
      resources.each do |resource|
        #binding.pry
        options[:ar] ? make_model(name, resource, true) : make_model(name, resource)
        make_controller(name, resource)
        config << "use #{controllerify(resource)}\n"
      end

      config << "run ApplicationController"
    end
  end

  desc "make_model", "make a new model"
  # From within the top level directory of the new Sinatra app, generate a model with the given name
  def make_model(app_name, model_name, ar=false)
    file_name = "#{model_name.singularize.downcase}.rb"
    model = File.new("./#{app_name}/app/models/#{file_name}", 'w')
    model << "class #{model_name.classify}"
    model << " < ActiveRecord::Base" if ar
    model << "\nend"
    model.close
  end

  
  desc "make_controller", "make a new controller"
  def make_controller(app_name, controller_name)
    file_name = "#{controller_name.pluralize.downcase}_controller.rb"
    controller = File.new("./#{app_name}/app/controllers/#{file_name}", 'w')
    controller << "class #{controllerify(controller_name)} < ApplicationController\nend"
    controller.close
  end

  private
    def environment_contents(ar=true)
      template = <<-BLOCK
ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

<% if ar %>
<%= active_record_connection_for_env %>
<% end %>

require_all 'app'
      BLOCK

      ERB.new(template, nil, '<>').result(binding)
    end

    def active_record_connection_for_env
      <<-BLOCK
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)
      BLOCK
    end

    def basic_gems
      ["'sinatra'", "'rake'", "'require_all'", "'thin'", "'shotgun'", "'pry'"]
    end

    def db_gems
      ["'activerecord', :require => 'active_record'", "'sinatra-activerecord', :require => 'sinatra/activerecord'"]
    end

    def test_gems
      ["'rspec'", "'capybara'", "'rack-test'"]
    end

    def db_test_gems
      ["'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'"]
    end

    def gemfile_contents(ar=true)
      #binding.pry
      all_gems = ar ? basic_gems + db_gems : basic_gems
      all_test_gems = ar ? test_gems + db_test_gems : test_gems

      template = <<-BLOCK
source 'http://rubygems.org'\n
<% all_gems.each do |gem| %>
gem <%= gem %>
<% end %>

group :test do
<% all_test_gems.each do |test_gem| %>
  gem <%= test_gem %>
<% end %>
end
      BLOCK

      ERB.new(template, nil, '<>').result(binding)
    end

    def config_ru_contents(ar=true)
      template = <<-BLOCK
require_relative './config/environment'

<% if ar %>
<%= config_ru_ar %>
<% end %>
      BLOCK

      ERB.new(template, nil, '<>').result(binding)
    end

    def config_ru_ar
      <<-BLOCK
if ActiveRecord::Migrator.needs_migration?
  raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
end

      BLOCK
    end

    def make_files(name, model_name)
      make_directory "~/app/models/#{model_name}"
      make_directory "~/app/models/#{model_name}"
    end

    def make_directory(name)
      FileUtils::mkdir_p name
    end

    def controllerify(name)
      "#{name.pluralize.capitalize}Controller"
    end

end

