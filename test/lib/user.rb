class User < ActiveRecord::Base
  
  belongs_to :role
  
  has_many :things, :foreign_key => 'owner_id'
  
  alias_method :position, :role

end
