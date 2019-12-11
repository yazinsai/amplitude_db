class Device < ApplicationRecord
  self.primary_key = "device_id"
  belongs_to :user, foreign_key: 'user_id'
  has_many :events, primary_key: 'device_id', foreign_key: 'device_id'
  def self.column_names
    super - ['created_at', 'updated_at', 'device_id']
  end
end
