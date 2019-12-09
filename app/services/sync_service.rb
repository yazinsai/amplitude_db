require 'zip'

class SyncService
  BASE_URL = 'https://amplitude.com/api/2/export'
  LAST_SYNC_FOLDER = 'last_sync_data'
  class << self
    def sync
      clear_dir
      download_dump
      parse_dump      
    end

    def period
      # data become available on server within 4 hours
      {
        start: (DateTime.now - 8.hours),
        end: (DateTime.now - 4.hours)
      }.transform_values{ |d| d.strftime("%Y%m%dT%H") }
    end

    private

    def parse_dump
      Dir["#{LAST_SYNC_FOLDER}/*"].each do |filepath|
        JSON.parse(File.read(filepath)).each do |hash|
          begin
            Event.create hash.slice(*Event.column_names)
          rescue => ex
            next
          end          
        end
      end
    end

    def download_dump
      response = client.get('', period)
      Zip::File.open_buffer(response.body) do |zip|
        zip.each{ |entry| extract_json(entry) }
      end
    end

    def format(str)
      str.insert(0,'[').insert(-1,']').gsub("\n",'').gsub(/}{/,"},{")        
    end

    def clear_dir
      unless Dir.empty?(LAST_SYNC_FOLDER)
        FileUtils.rm_rf(Dir["#{LAST_SYNC_FOLDER}/*"])
      end
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
