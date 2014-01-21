namespace :api_queue do
  desc "empties the queue and deletes the logs"
  task reset: :environment do
    ApiQueue.hard_reset!
  end

  desc "clears and populates the queue with companies to import"
  task :populate, [:source] => [:environment] do |t, args|
    ApiQueue.populate!(data_source: (args.source || :crunchbase))
  end

  desc "starts the queue workers - defaults to 5 workers"
  task :start_workers, [:workers] => [:environment] do |t, args|
    ApiQueue.start_workers(args.workers)
  end

  desc "uploads gzipped json data to S3 and sets the ACL to public"
  task upload_data: :environment do
    ApiQueue.upload_fakedata
  end

  desc "flushes the queue, re-populates it, starts the workers to process the queue, and uploads json to S3"
  task :run, [:workers, :source] => [:environment] do |t, args|
    ApiQueue.run((args.workers || 5), data_source: (args.source || :crunchbase))
  end
end
