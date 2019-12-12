class SyncService
  class Modeler
    attr_reader :params_ary

    def initialize(params_ary)
      @params_ary = params_ary
    end

    def mold
      params_ary.each do |hash|        
        begin
          user_params = hash.slice('device_id', 'user_id', 'user_properties').values
          user = create_user(*user_params)

          device_params = hash.slice(*Device.column_names)
          device = create_device(device_params, user)

          create_event(hash, device)
        rescue => ex
          next
        end          
      end
    end

    def create_event(params, device)
      event_params = params.slice(*Event.column_names).merge({'device' => device})
      Event.create(event_params)
    end

    def create_device(params, user = nil)
      Device.find_or_create_by(device_id: params['device_id']).tap do |device|
        device.update(user: user) unless device.user.present?
        assign_unless_present(device, params, *Device.column_names)
      end
    end

    def create_user(device_id, user_id = nil, user_properties = nil)
      byebug
      ( find_user_by(device_id: device_id) || find_user_by(user_id: user_id) )
        .tap{ |user| update_user_fields(user, user_id, user_properties) }
    end

    private

    def find_user_by(device_id: nil, user_id: nil)
      if device_id.present?
        User.joins(:devices).where(devices: { device_id: device_id }).take
      elsif user_id.present?
        User.find_or_create_by(amplitude_user_id: user_id)
      end
    end

    def update_user_fields(user, user_id, user_properties)
      if user_id.present? && user.amplitude_user_id.match?(/^\d+$/)
        # update with amal's app uuid 
        user.update(amplitude_user_id: user_id)
      end
      assign_unless_present(user, user_properties, 'email', 'ref')
    end

    def assign_unless_present(to, from, *fields)
      return unless to.present? && from.present?
      fields.each{ |f| to[f] = from[f] unless to[f].present? }
      to.save
    end
  end
end