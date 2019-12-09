class Event < ApplicationRecord
  serialize :data, Hash
  serialize :event_properties, Hash
end
