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
  # Pass in an empty string to avoid ArgumentError
  def make_sinatra_skeleton(name="", *models)
    if name == ""
      puts "You must specify a name for your new Sinatra app."
    else
      # Does not make another one if exists
      make_directory "#{name}/app"
      make_directory "#{name}/app/models"
      make_directory "#{name}/app/controllers"
      make_directory "#{name}/app/views"
      File.new("#{name}/config.ru", 'w') 
    end
  end

  desc "make_model", "make a new model"
  # From within the top level directory of the new Sinatra app, generate a model with the given name
  def make_model(name)
    file_name = "#{name.singularize.downcase}.rb"
    model = File.new("./app/models/#{file_name}", 'w')
    model << "class #{name.classify} < ActiveRecord::Base\nend"
    model.close
  end

  
  desc "make_controller", "make a new controller"
  def make_controller(name)
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

