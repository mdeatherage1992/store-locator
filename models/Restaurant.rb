require 'mongoid'
class Restaurant
  include Mongoid::Document
  field :name, :type => String
end
