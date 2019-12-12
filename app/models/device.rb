class Device < ApplicationRecord
  self.primary_key = "device_id"
  belongs_to :user, optional: true
  has_many :events, primary_key: 'device_id', foreign_key: 'device_id'
end
