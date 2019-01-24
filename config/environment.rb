require 'sinatra'
ENV['SINATRA_ENV'] ||= "development"
require 'mongoid'
require 'mongo'
require 'haml'
require 'bundler/setup'
require './app'

Bundler.require(:default, ENV['SINATRA_ENV'])
