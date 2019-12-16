class SyncService
  # { zipped_folder: [ file1.json.gz, file2.json.gz ] } -> [ file1_json_str, file1_json_str ]
  class Extractor
    DOWNLOAD_FOLDER = 'download'
    
    def initialize(zipped_data)
      @data = zipped_data
    end

    def extract
      begin
        extract_zip
        extract_gz
      ensure
        clear_dir
      end
    end

    def extract_zip(path = DOWNLOAD_FOLDER)
      Zip::File.open_buffer(@data).each do |entry|
        FileUtils.mkdir_p(path)
        output_path = "#{path}/#{File.basename(entry.name)}"
        entry.extract(output_path)
      end
    end

    def extract_gz(filenames = Dir["#{DOWNLOAD_FOLDER}/*.gz"])
      filenames.flat_map do |file|        
        MultipleFilesGzipReader.new(File.open(file)).readlines
      end
    end

    private
    
    def clear_dir(path = DOWNLOAD_FOLDER)
      FileUtils.rm_rf(Dir["#{path}/*"])
    end
  end
end