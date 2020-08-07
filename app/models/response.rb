class Response < ApplicationRecord
  belongs_to :event, optional: :true
  belongs_to :hero, optional: :true
end