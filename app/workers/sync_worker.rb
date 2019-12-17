class SyncWorker
  include Sidekiq::Worker

  def perform
    SyncService.new.sync
  end
end
