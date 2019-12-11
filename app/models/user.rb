class User < ApplicationRecord
  self.primary_key = "user_id"
  has_many :devices, primary_key: 'user_id', foreign_key: 'user_id'
  has_many :events, through: :devices
end
