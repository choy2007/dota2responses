class Hero < ApplicationRecord
  has_many :responses
  
  validates_uniqueness_of :name
end