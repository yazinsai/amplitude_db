class Event < ApplicationRecord
  belongs_to :device, foreign_key: 'device_id'
  has_one :user, through: :device
end
