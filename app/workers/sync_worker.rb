class SyncWorker
  include Sidekiq::Worker

  def perform
    SyncService.sync
  end
end
