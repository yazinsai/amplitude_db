require 'zip'

class SyncService
  BASE_URL = 'https://amplitude.com/api/2/export'

  attr_reader :from_time, :to_time, :keep_last

  def initialize(from_time: (DateTime.now - 8.hours), to_time: (DateTime.now - 4.hours), keep_last: true)
    @from_time = from_time
    @to_time = to_time
    @keep_last = keep_last
  end
  
  def sync
    Extractor.new(download_dump, keep_last: keep_last)
      .extract.then{ |hashes| Modeler.new(hashes).mold }
  end

  private

  def download_dump
    # It returns 404 if there is no stats for specified period
    response = OpenStruct.new(status: nil)
    until response.status == 200 do
      response = client.get('', period)
      @from_time -= 1.hour
      @to_time -= 1.hour
    end
    response.body
  end

  def client
    Faraday.new(url: BASE_URL, request: { timeout: 3_600 }) do |conn|
      conn.adapter Faraday.default_adapter
      conn.basic_auth(ENV['AMPLITUDE_API_KEY'], ENV['AMPLITUDE_SECRET_KEY'])
    end
  end

  def period
    { start: from_time, end: to_time }
      .transform_values{ |d| d.strftime("%Y%m%dT%H") }
  end
end
