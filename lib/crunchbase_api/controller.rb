module ApiQueue
  # delegate method calls made to the ApiQueue module itself to the Controller class
  # if the method is not already defined on the ApiQueue module
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

  class Controller

    # logs text into the logfile
    #
    # @param [String] text the text to be logged
    def self.log(text)
      puts text
      File.open("#{Rails.root}/log/controller_log.log", "a"){|f| f.puts(Time.now.strftime("%m/%d/%Y %T") + ' ' + text)}
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
    def self.run(num_workers = 5, data_source: :crunchbase)
      hard_reset!
      populate!(data_source: data_source)
      supervisor = ApiQueue::Supervisor.new
      supervisor.start_workers(num_workers)
    end

    # populate the queue with all elements in the index action for the given namespace
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, Array<Symbol>] namespace the entity type or types to enqueue
    def self.populate(data_source: :crunchbase, namespace: :company)
      api = "ApiQueue::Source::#{data_source.to_s.classify}".constantize
      [*namespace].each do |ns|
        permalinks = api.get_entities(ns)
        ApiQueue::Queue.batch_enqueue(ns, permalinks, data_source)
      end
    end

    # populates with n random entities
    def self.populate_random(data_source: :crunchbase, namespace: :company, n: 2000)
      api = "ApiQueue::Source::#{data_source.to_s.classify}".constantize
      [*namespace].each do |ns|
        permalinks = api.get_random_entities(ns, n)
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
      populate(data_source: data_source, namespace: namespaces)
    end

    # populate the queue with only those elements in the given namespace
    # that are not currently represented in both local and s3
    #
    # @param [Symbol] data_source the source api to use. options are :crunchbase, :s3, :local
    # @param [Symbol, Array<Symbol>] namespace the entity type or types to enqueue
    def self.populate_missing(data_source: :crunchbase, archive: [:local,:s3], namespace: :company, process: false, num_workers: 5)
      available = ApiQueue::Source::Crunchbase.get_entities(namespace)
      already_have = ApiQueue::Source::S3.get_entities(namespace)
      permalinks = available - already_have
      ApiQueue::Queue.batch_enqueue(namespace, permalinks, data_source)
      start_workers(num_workers, archive: archive, process: process)
    end

    # makes a request to an endpoint and uploads the result to s3
    def self.upload_fakedata
      letters = ['0',*('a'..'z')]

      endpoints = {}
      endpoints["categories"] = "fakedata/categories.json"
      letters.each{|letter| endpoints["companies?letter=#{letter}"] = "fakedata/companies/#{letter}.json"}
      letters.each{|letter| endpoints["investors?letter=#{letter}"] = "fakedata/investors/#{letter}.json"}

      endpoints.each_pair do |api_endpoint, s3_filename|
        response = query_app(endpoint: api_endpoint)
        log 'parsing json to confirm validity'
        JSON.parse(response.body) # this will error if the response isn't valid json
        log "uploading json to 'temp.crunchinator.com' bucket as '#{s3_filename}' and exposing to public"
        ApiQueue::Source::S3.upload_and_expose('temp.crunchinator.com', s3_filename, response.body)
      end
    end

    # makes a request to an endpoint and return the result
    def self.query_app(controller_method: :get, endpoint: :companies)
      log "querying #{endpoint.inspect} endpoint and capturing response"
      app = fakeapp
      app.send(controller_method.to_sym, "/v1/#{endpoint}")
      app.response
    end

    private

    # returns an application object that can be queried
    def self.fakeapp
      if !defined?(ActionDispatch::Integration::Session) 
        require "action_dispatch/integration"
      end
      ActionDispatch::Integration::Session.new(Crunchinator::Application)
    end

  end
end