require './config/environment'
require 'sinatra/base'
require 'thin'
require 'mongo'
require 'rubygems'
require 'mongoid'
require 'geocoder'
require "pry"
require 'json/ext'
require 'cgi'
require_relative "./models/area"
require_relative './models/restaurant'
include Geocoder::Model::Mongoid
class ApplicationController < Sinatra::Base


  configure do
  begin
    @@mongo_db = Mongo::Client.new(['127.0.0.1:27017'], database: "db" )
    @@new_mongo = @@mongo_db[:areas]
    @@mongo_stores = @@mongo_db[:stores]
    @grid_1 = @@mongo_stores.indexes.create_one( { "stores" => "2dsphere" } )
    @grid = @@new_mongo.indexes.create_one( { 'location.boundaries' => '2dsphere' })
    @@mongo_restaurants = @@mongo_db[:restaurants]
    set :mongo_db, @@mongo_db
    set :views, "/Users/matthewdeatherage/desktop/j-media/views"
  rescue Mongo::ConnectionFailure
    set :mongo_db, {}
  end
end

helpers do
end

  #for Rake
    # def self.mongo_db
    #   @mongo_db = Mongo::Client.new(['127.0.0.1:27017'], database: "db" )
    #   @db = @mongo_db.database
    #   self.database.push(@db)
    #   return self.database
    # end

    get "/?" do
      "Hello visitor "

      haml :index
    end

    get "/area?" do
      @param_1 = "#{params[:lat]}".to_i
      @param_2 = "#{params[:lng]}".to_i
      @param_final = [@param_1,@param_2]
      @all = []
      @coordinates = []
      @@new_mongo.find(
      { "boundaries" =>
        { "$geoIntersects" =>
         { "$geometry" =>
   	       { "type" => "Point" ,
              "coordinates" => @param_final
            }
          }
        }
      }
    ).each do |doc|
      @all.push(doc)
    end
    @all
      haml :area_render
    end

    get "/restaurants?" do
      @param_1 = "#{params[:lat]}".to_i
      @param_2 = "#{params[:lng]}".to_i
      @param_3 = "#{params[:distance]}".to_i
      @param_final = [@param_1,@param_2]
      @rest_and_store = []
      @stores = []
      @rest = []
      @@mongo_stores.find({
  "loc" => {
    "$nearSphere" => {
        "$geometry" => {
          "type" =>'Point',
          "coordinates" => @param_final
        },
        "$maxDistance" => (@param_3 * 1609.344)
    }
  }
}).each do |doc|
      @stores.push(doc)
    end
setter = @stores[0]["rid"].split('-').join(' ')
@name = setter.split.each { |item| item.capitalize! }.join(' ')
@@mongo_restaurants.find({"name" => @name }).each do |doc|
  @rest.push(doc)
end
@rest_and_store.push(@rest[0])
@rest_and_store.push(@stores[0])
@store_coords = @rest_and_store[1]["loc"]
@@new_mongo.find(
{ "boundaries" =>
  { "$geoIntersects" =>
   { "$geometry" =>
     { "type" => "Point" ,
        "coordinates" => @store_coords
      }
    }
  }
}
).each do |doc|
  @rest_and_store.push(doc)
end
    haml :restaurants
  end



end
