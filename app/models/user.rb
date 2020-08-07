class User < ApplicationRecord
  has_many :messages
  
  validates_uniqueness_of :username
  
  def self.generate
    ign = Faker::Games::Dota.player
    create(username: ign)
  end
end