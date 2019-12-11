class SyncService
  # { zipped_folder: [ file1.json.gz, file2.json.gz ] } -> [ file1_json_str, file1_json_str ]
  class Extractor
    LAST_SYNC_FOLDER = 'last_sync_data'
    
    def initialize(zipped_data, keep_last: false)
      @data = zipped_data
      @keep_last = keep_last
    end

    def extract
      Zip::File.open_buffer(@data)
        .flat_map{ |entry| extract_json(entry) }
    end

    private

    def keep_last?
      @keep_last
    end

    def extract_json(entry)
      Zlib::GzipReader.new(entry.get_input_stream)
        .then{ |input| format(input.read) }
        .tap{ |data| save_file(data, entry.name) if keep_last? }
    end

    def format(str)
      str.insert(0,'[').insert(-1,']')
        .gsub("\n",'').gsub(/}{/,"},{")
        .then(&JSON.method(:parse))
    end

    def save_file(data, filename)
      # keeps files only from last sync
      unless Dir.empty?(LAST_SYNC_FOLDER)
        FileUtils.rm_rf(Dir["#{LAST_SYNC_FOLDER}/*"])
      end

      path = File.join(LAST_SYNC_FOLDER, File.basename(filename).sub(/.gz$/,''))
      File.open(path, "w") do |output_stream|
        output_stream << data.to_json
      end
    end
  end
end