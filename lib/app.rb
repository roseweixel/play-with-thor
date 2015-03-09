require 'thor'
require 'fileutils'
require 'pry'
require 'active_support/core_ext/string'

class CLI < Thor
  package_name "App"
  map "l" => :list

  desc "list [SEARCH]", "show a list of things"
  def list(search="")
    puts "List #{search}"
  end

  desc "make_directory", "make a new directory"
  option :noar, :type => :boolean
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
      
      ## Make top level files
      # generate config.ru
      File.new("#{name}/config.ru", 'w')

      # generate application_controller.rb
      application_controller = File.new("#{name}/app/controllers/application_controller.rb", 'w')
      application_controller << "class ApplicationController < Sinatra::Base\nend"

      # generate Gemfile
      gemfile = File.new("#{name}/Gemfile", 'w')
      gemfile << "source 'http://rubygems.org'\n\ngem 'sinatra'"
      gemfile << "\ngem 'activerecord', :require => 'active_record'\ngem 'sinatra-activerecord', :require => 'sinatra/activerecord'" unless options[:noar]

      # generate models
      resources.each do |resource|
        #binding.pry
        options[:noar] ? make_model(name, resource) : make_model(name, resource, true)
        make_controller(name, resource)
      end

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

