require 'json'
require 'logger'

require 'sinatra/base'
require 'sinatra/flash'
require 'slim'
require 'mongo'
require 'hashie/mash'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'pry'

require 'action_view'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'lib/mongo_admin/db'

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper

module MongoAdmin
  class App < Sinatra::Base
    Mongo::Logger.logger.level = Logger::WARN

    configure do
      set :logging, true
      set :views, 'app/views'
      set :public_dir, 'public'
      set :root, (settings.root || File.dirname(__FILE__))
      set :config_file, JSON.load(File.open("config_#{ENV['RACK_ENV']}.json"))
      set :method_override, true
      set :locale, 'en'
      set :db, DB.new(settings.config_file)


      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.locale = 'en'
      I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
      I18n.backend.load_translations
      I18n.enforce_available_locales = false
    end


    enable :sessions

    register Sinatra::Flash
  end
end

require_relative 'lib/sinatra-flash'


# Routes
require_relative 'app/routes/index'
