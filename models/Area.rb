
class Area
  include Mongoid::Document
  field :boundaries, :type => Object
  field :type, :type => String
  field :coordinates, :type => Array

end
