class SyncService
  class Modeler
    attr_reader :params_ary

    def initialize(params_ary)
      @params_ary = params_ary
    end

    def mold
      params_ary.each do |hash|
        create_models(hash)
        # begin
        #   create_models(hash.symbolize_keys)
        # rescue => ex
        #   next
        # end          
      end
    end

    def create_models(params)
      # create event
      event = Event.create params.slice(*Event.column_names)
      # create device
      Device.find_or_create_by(device_id: event.device_id).tap do |device|
        assign_unless_present(device, event, *Device.column_names)
      end
      # create user
      if params['user_id'].present?
        User.find_or_create_by(user_id: params['user_id']).tap do |user|
          assign_unless_present(user, event.user_properties, 'email', 'ref')
        end
      end
    end

    private

    def assign_unless_present(to, from, *fields)
      return unless from.present?
      fields.each{ |f| to[f] = from[f] unless to[f].present? }
      to.save!
    end
  end
end