require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'mongo'
require 'thin'

    configure do
      Mongoid.load!("./mongoid.yml",:development)
    end
