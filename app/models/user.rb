class User < ApplicationRecord
  has_many :devices
  has_many :events, through: :devices
end
