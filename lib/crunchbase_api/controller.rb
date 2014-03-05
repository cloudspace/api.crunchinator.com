# A namespace to contain all classes/modules relating to the queue/worker system
module ApiQueue
  # delegate method calls made to the ApiQueue module itself to the Controller class
  #   if the method is not already defined on the ApiQueue module
  def self.method_missing(name, *args)
    ApiQueue::Controller.respond_to?(name) ? ApiQueue::Controller.send(name, *args) : super(name, *args)
  end

  # make the ApiQueue module accurately report that it has Controller's class methods
  def self.respond_to?(name)
    super || ApiQueue::Controller.respond_to?(name)
  end

  def self.methods
    (super + (ApiQueue::Controller.methods - Class.methods)).uniq
  end

  # The interface for the queue/worker system. All class methods on this class are
  #   delegated to the ApiQueue module for convenience. I.e., 'ApiQueue.method_name'
  #   is exactly the same as 'ApiQueue::Controller.method_name'.
  class Controller

    # clears the queue and flushes the logs
    def self.hard_reset!
      log 'clearing the queue and the logs'
      ApiQueue::Queue.clear!
      Dir["#{Rails.root}/log/import_worker*"].select { |f| File.delete(f) }
      File.delete("#{Rails.root}/log/supervisor.log") if File.exists?("#{Rails.root}/log/supervisor.log")
      File.delete("#{Rails.root}/log/controller.log") if File.exists?("#{Rails.root}/log/controller.log")
    end

    # flushes the logs, deletes the local json files, populates the queue, starts workers to process
    #   the queue, then uploads the data to S3.
    #
    # Examples:
    #
    #     # Run 5 workers, pull data from crunchbase, archive it locally and on s3, and process it
    #     ApiQueue.run
    #
    #     # Run 10 workers, using data from S3, do not archive any data
    #     ApiQueue.run(10, data_source: :s3, archive: false)
    #
    #     # Run 8 workers, using data from crunchbase, archive data only to :s3
    #     ApiQueue.run(8, archive: :s3)
    #
    #     # Run 5 workers, pull data from crunchbase and archive it, but do not process it or upload json to S3
    #     ApiQueue.run(process: false, upload: false)
    #
    # @param [FixNum] num_workers the number of workers to start
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, String, Array<Symbol>, Array<String>, false, nil] archive the location or
    #   locations to which to archive the json. Corresponds to the name of a class in the
    #   ApiQueue::Sourcenamespace. If this is false or nil, the json will not be archived.
    # @param [FixNum] process a flag which controls whether or not the importer will attempt
    #   to create database objects out of the json
    # @param [FixNum] upload a flag which controls whether or not the importer will attempt
    #   to upload fresh json to S3 after fully processing the queue
    def self.run(num_workers = 5, data_source: :crunchbase, archive: [:local, :s3], process: true, upload: true)
      fail 'you must either archive or process the data' unless archive || process
      populate!(data_source: data_source)
      success = start_workers(num_workers)
      cache_json if upload && success
    end

    # flushes the logs, deletes the local json files,
    #   populates the queue, and starts the workers
    #
    # Examples:
    #
    #     # Run 5 workers, archive the data locally and on s3, and process the data
    #     ApiQueue.start_workers
    #
    #     # Run 10 workers, do not archive the data, and process the data
    #     ApiQueue.start_workers(10, archive: false)
    #
    #     # Run 8 workers, archive the data on S3 only, and process the data
    #     ApiQueue.start_workers(8, archive: :s3)
    #
    #     # Run 5 workers, archive the data locally and on s3, but do not process it
    #     ApiQueue.start_workers(process: false)
    #
    # @param [FixNum] num_workers the number of workers to start
    # @return [Boolean] true if all workers exited normally due ot the queue being empty, else false
    def self.start_workers(num_workers = 5, archive: [:local, :s3], process: true)
      log "starting #{num_workers} archiving at #{archive.inspect}, processing is #{process ? 'on' : 'off'}"
      supervisor = ApiQueue::Supervisor.new(archive: archive, process: process)
      supervisor.start_workers(num_workers)
    end

    # populate the queue with all elements in the index action for the given namespace
    #
    # Examples:
    #
    #     # populates the queue with a list of entities for the company namespace using
    #     # crunchbase's api as the data source
    #     ApiQueue.populate
    #
    #     # populates the queue with a list of entities for the company and person
    #     # namespaces using crunchbase's api as the data source
    #     ApiQueue.populate(namespaces: [:company, :person])
    #
    #     # populates the queue with a list of entities for the person namespace
    #     # using S3 as the data source
    #     ApiQueue.populate(data_source: :s3, namespace: :person)
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, Array<Symbol>] namespace the entity type to enqueue (interchangeable with namespaces)
    # @param [Symbol, Array<Symbol>] namespaces multiple entity types to enqueue (interchangeable with namespace)
    def self.populate(data_source: :crunchbase, namespace: nil, namespaces: nil)
      namespaces = [*(namespace || namespaces || :company)]
      log "populating queue using source #{data_source.inspect}, in namespaces #{namespaces.inspect}"
      api = "ApiQueue::Source::#{data_source.to_s.classify}".constantize
      [*namespaces].each do |ns|
        permalinks = api.fetch_entities(ns)
        ApiQueue::Queue.batch_enqueue(ns, permalinks, data_source)
      end
    end

    # empty the queue and repopulate it with all endpoints in a namespace. this takes exactly the same arguments
    #   and works the same as the populate method above, with the only distinction being that this method
    #   first empties the queue
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol] namespace the entity type to enqueue
    def self.populate!(*args)
      ApiQueue::Queue.clear!
      populate(*args)
    end

    # empty the queue and repopulate it with all endpoints in all namespaces
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    def self.populate_all!(data_source: :crunchbase)
      ApiQueue::Queue.clear!
      namespaces = %w[company person financial-organization]
      populate(data_source: data_source, namespaces: namespaces)
    end

    # populate the queue with only those elements in the given namespace
    # that are not currently represented in both local and s3
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, Array<Symbol>] namespace the entity type to enqueue
    def self.populate_missing(data_source: :crunchbase, namespace: nil)
      available = ApiQueue::Source::Crunchbase.fetch_entities(namespace)
      already_have = ApiQueue::Source::S3.fetch_entities(namespace)
      permalinks = available - already_have
      ApiQueue::Queue.batch_enqueue(namespace, permalinks, data_source)
    end

    # makes requests to all endpoints and uploads the results to s3
    # this does nothing when run in any environment other than staging or production
    def self.cache_json
      version = Crunchinator::Application::VERSION

      endpoints = {}
      endpoints['categories'] = "api/#{version}/categories.json"
      endpoints['companies'] = "api/#{version}/companies.json"
      endpoints['investors'] = "api/#{version}/investors.json"
      endpoints['funding_rounds'] = "api/#{version}/funding_rounds.json"

      endpoints.each_pair do |api_endpoint, s3_filename|
        response = query_app(endpoint: api_endpoint)
        log 'parsing json to confirm validity'
        JSON.parse(response.body) # this will error if the response isn't valid json
        log "uploading json to bucket as '#{s3_filename}' and exposing to public"
        ApiQueue::Source::S3.upload_and_expose(s3_filename, response.body)
      end

      current_release = { release: version }.to_json
      ApiQueue::Source::S3.upload_and_expose('api/current_release.json', current_release, gzip: false)
    end

    # makes a request to an endpoint on the crunchinator app and returns the result
    #
    # @param [Symbol, String] controller_method the http method to use (:get, :post, etc)
    # @param [Symbol, String] endpoint the endpoint to query (:companies, :investors, etc)
    # @return [ActionDispatch::TestResponse] the response from the api
    def self.query_app(controller_method: :get, endpoint: :companies)
      require 'action_dispatch/integration' unless defined?(ActionDispatch::Integration::Session)
      app = ActionDispatch::Integration::Session.new(Crunchinator::Application)
      log "querying #{endpoint.inspect} endpoint and capturing response"
      app.send(controller_method.to_sym, "/v1/#{endpoint}")
      app.response
    end

    private

    # logs text into the logfile
    #
    # @param [String] text the text to be logged
    def self.log(text)
      Rails.logger.info text
      File.open("#{Rails.root}/log/controller.log", 'a') do |f|
        f.puts(Time.now.strftime('%m/%d/%Y %T') + ' ' + text)
      end
    end
  end
end
