require 'mongoid'
class Store
  include Mongoid::Document
  field :number, :type => Integer
  field :rid, :type => String
  field :loc, :type => Array


end
