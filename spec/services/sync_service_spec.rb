require 'rails_helper'

RSpec.describe SyncService do
  describe 'extraction' do
    let(:zipped_data) { File.read('spec/spec_data/archive.zip') }
    let(:json_data) do
      [
        {
          "one" => "1",
          "two" => "2"
        },
        {
          "three" => "3",
          "four" => "4"
        },
        {
          "1" => "one",
          "2" => "two"
        },
        {
          "3" => "three",
          "4" => "four"
        }
      ]
    end

    it 'extracts properly' do
      extracted_data = SyncService::Extractor.new(zipped_data).extract
      expect(extracted_data).to eq json_data
    end
  end
end
