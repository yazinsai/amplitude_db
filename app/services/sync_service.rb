require 'zip'

class SyncService
  BASE_URL = 'https://amplitude.com/api/2/export'
  LAST_SYNC_FOLDER = 'last_sync_data'
  EVENT_FIELDS = %w(
    uuid
    user_id
    device_id
    email
    device_type
    event_type
    event_properties
    data
    country
    region
    city
    referrer
    event_time   
  )
  class << self
    def sync
      clear_dir
      download_dump
      parse_dump      
    end

    def period
      {
        start: (DateTime.now - 24.hour),
        end: DateTime.now
      }.transform_values{ |d| d.strftime("%Y%m%dT%H") }
    end

    private

    def parse_dump
      Dir["#{LAST_SYNC_FOLDER}/*"].each do |filepath|
        JSON.parse(File.read(filepath)).each do |hash|
          create_event(hash)
        end
      end
    end

    def download_dump
      response = client.get('', period)
      Zip::File.open_buffer(response.body) do |zip|
        zip.each{ |entry| extract_json(entry) }
      end
    end

    def create_event(hash)
      Event.create hash.slice(*EVENT_FIELDS)
    end

    def format(str)
      str.insert(0,'[').insert(-1,']').gsub("\n",'').gsub(/}{/,"},{")        
    end

    def clear_dir
      
    end

    def extract_json(entry)
      input_stream = Zlib::GzipReader.new(entry.get_input_stream)

      path = File.join(LAST_SYNC_FOLDER, File.basename(entry.name).sub(/.gz$/,''))
      File.open(path, "w") do |output_stream|
        # IO.copy_stream(input_stream, output_stream)
        output_stream << format(input_stream.read)
      end
    end

    def client
      Faraday.new(url: BASE_URL) do |conn|
        conn.adapter Faraday.default_adapter
        conn.basic_auth(ENV['AMPLITUDE_API_KEY'], ENV['AMPLITUDE_SECRET_KEY'])
      end
    end
  end
end
