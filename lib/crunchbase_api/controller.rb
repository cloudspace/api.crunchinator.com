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
  #   delegated to the ApiQueue module for convenience.
  class Controller
    # logs text into the logfile
    #
    # @param [String] text the text to be logged
    def self.log(text)
      Rails.logger.info text
      File.open("#{Rails.root}/log/controller_log.log", 'a') do |f|
        f.puts(Time.now.strftime('%m/%d/%Y %T') + ' ' + text)
      end
    end

    # clears the queue and flushes the logs
    def self.hard_reset!
      ApiQueue::Queue.clear!
      `rm #{Rails.root}/log/import_worker*`
    end

    # flushes the logs, deletes the local json files,
    # populates the queue, and starts the workers
    #
    # @param [FixNum] num_workers the number of workers to start
    def self.run(num_workers = 5, data_source: :crunchbase, archive: [:local, :s3], process: true)
      hard_reset!
      populate!(data_source: data_source)
      supervisor = ApiQueue::Supervisor.new(archive: archive, process: process)
      supervisor.start_workers(num_workers)
    end

    # populate the queue with all elements in the index action for the given namespace
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, Array<Symbol>] namespace the entity type to enqueue (interchangeable with namespaces)
    # @param [Symbol, Array<Symbol>] multiple entity types to enqueue (interchangeable with namespace)
    def self.populate(data_source: :crunchbase, namespace: nil, namespaces: nil)
      namespaces = [*(namespace || namespaces || :company)]
      api = "ApiQueue::Source::#{data_source.to_s.classify}".constantize
      [*namespaces].each do |ns|
        permalinks = api.fetch_entities(ns)
        ApiQueue::Queue.batch_enqueue(ns, permalinks, data_source)
      end
    end

    # empty the queue and repopulate it with all endpoints in a namespace
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
    # @param [Symbol, Array<Symbol>] namespace the entity type to enqueue (interchangeable with namespaces)
    # @param [Symbol, Array<Symbol>] multiple entity types to enqueue (interchangeable with namespace)
    def self.populate_missing(data_source: :crunchbase, namespace: nil, namespaces: nil)
      namespaces = [*(namespace || namespaces || :company)]
      available = ApiQueue::Source::Crunchbase.fetch_entities(namespace)
      already_have = ApiQueue::Source::S3.fetch_entities(namespace)
      permalinks = available - already_have
      ApiQueue::Queue.batch_enqueue(namespace, permalinks, data_source)
    end

    # makes a request to an endpoint and uploads the result to s3
    def self.upload_fakedata
      letters = ['0', *('a'..'z')]

      endpoints = {}
      endpoints['categories'] = 'fakedata/categories.json'
      endpoints['companies'] = 'fakedata/companies.json'
      endpoints['investors'] = 'fakedata/investors.json'
      letters.each { |letter| endpoints["companies?letter=#{letter}"] = "fakedata/companies/#{letter}.json" }
      letters.each { |letter| endpoints["investors?letter=#{letter}"] = "fakedata/investors/#{letter}.json" }

      endpoints.each_pair do |api_endpoint, s3_filename|
        response = query_app(endpoint: api_endpoint)
        log 'parsing json to confirm validity'
        JSON.parse(response.body) # this will error if the response isn't valid json
        log "uploading json to 'temp.crunchinator.com' bucket as '#{s3_filename}' and exposing to public"
        ApiQueue::Source::S3.upload_and_expose('temp.crunchinator.com', s3_filename, response.body)
      end
    end

    # makes a request to an endpoint on the crunchinator app and returns the result
    #
    # @param [Symbol, String] controller_method the http method to use (:get, :post, etc)
    # @param [Symbol, String] endpoint the endpoint to query (:companies, :investors, etc)
    # @return [ActionDispatch::TestResponse] the response from the api
    def self.query_app(controller_method: :get, endpoint: :companies)
      log "querying #{endpoint.inspect} endpoint and capturing response"
      app = fakeapp
      app.send(controller_method.to_sym, "/v1/#{endpoint}")
      app.response
    end

    private

    # returns an application object that can be queried
    #
    # @return [ActionDispatch::Integration::Session] the app object to which requests can be made
    def self.fakeapp
      require 'action_dispatch/integration' unless defined?(ActionDispatch::Integration::Session)
      ActionDispatch::Integration::Session.new(Crunchinator::Application)
    end

  end
end
