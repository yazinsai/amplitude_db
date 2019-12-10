require 'zip'

class SyncService
  BASE_URL = 'https://amplitude.com/api/2/export'
  LAST_SYNC_FOLDER = 'last_sync_data'
  class << self
    def sync(from: (DateTime.now - 8.hours), to: (DateTime.now - 4.hours))
      clear_dir
      extract_data download_dump(from, to)      
      parse_dump      
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

    def download_dump(from, to)
      # It returns 404 if there is no stats for specified period
      response = OpenStruct.new(status: nil)
      until response.status == 200 do
        period = { start: from, end: to }
          .transform_values{ |d| d.strftime("%Y%m%dT%H") }
        response = client.get('', period)
        from -= 1.hour
        to -= 1.hour
      end
      response.body
    end

    def extract_data(dump)
      Zip::File.open_buffer(dump) do |zip|
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
      Faraday.new(url: BASE_URL, request: { timeout: 3_600 }) do |conn|
        conn.adapter Faraday.default_adapter
        conn.basic_auth(ENV['AMPLITUDE_API_KEY'], ENV['AMPLITUDE_SECRET_KEY'])
      end
    end
  end
end
