# rubocop:disable all
# this is an experiment. i'm trying to come up with a clean way
# to select just those attributes to assign attributes to model
# instances from api data, and translate those keys which must be changed.
# don't use this yet, it is ugly and subject to change and/or deletion

module ApiQueue
  class Normalizer
    attr_reader :permitted_attrs, :translations, :key_attr

    def initialize(*args)
      args = args.map{|a| a.respond_to?(:to_sym) ? a.to_sym : a.symbolize_keys}
      lambda{|*array, **hash| @permitted_attrs = array; @translations = hash}.call(*args)
    end

    def process_attributes(args)
      attrs = args.symbolize_keys!.select{|k,v| @permitted_attrs.include?(k)}
      @translations.each{|k,v| attrs[v] = args[k] if args.has_key?(k)}
      attrs.symbolize_keys!
    end

    def self.key_attr(attribute)
      @key_attr = attribute.to_sym
    end

    def self.normalize(*args)
      @normalizer = self.new(*args)
    end

    def normalizer
      self.class.instance_variable_get(:@normalizer)
    end

    def key_attr
      self.class.instance_variable_get(:@key_attr)
    end

    def self.mutex
      @mutex ||= Mutex.new
    end

    def mutex
      self.class.mutex
    end

    # def self.inherited(subclass)
    #   @model = subclass.to_s.underscore.split('_').first.classify.constantize
    #   @model.instance_eval do
    #     @normalizer = "#{self.name}Normalizer".constantize.normalizer

    #     def self.make_with(*args)
    #       @normalizer.mutex.synchronize do
    #         self.transaction do
    #           entity = self.find_or_create_by(@normalizer.key_attr => args.symbolize_keys![@normalizer.key_attr])
    #           filtered_attributes = @normalizer.process_attributes(*args)
    #           entity.update_attributes(filtered_attributes)
    #           entity
    #         end
    #       end
    #     end
    #   end
    # end
  end
end

class PersonNormalizer < ApiQueue::Normalizer
end
class CompanyNormalizer < ApiQueue::Normalizer
  key_attr :permalink
  normalize :permalink, :crunchbase_url, :homepage_url, :blog_url, :blog_feed_url, :twitter_username, :number_of_employees, :founded_year, :founded_month, :founded_day, :deadpooled_year, :deadpooled_month, :deadpooled_url, :tag_list, :alias_list, :email_address, :phone_number, :description, :overview, :deadpooled_day
end

    # # does a find_or_create_by in a threadsafe transaction to ensure no duplicates
    # # are created, or errors caused by 2 threads trying to create the same entity
    # #
    # # @param [Class] klass the class for which you want to find or create
    # # @param [Hash{String => String}] condition the attribute name and value to find/create by
    # # @yield optional block containing attributes to assign/update
    # # @yieldreturn [Hash] extra attributes to assign/update
    # # @return [Person] the newly created person.
    # def safe_find_or_create_by(key_attribute, attributes)
    #   attributes = ActiveSupport::HashWithIndifferentAccess.new_from_hash_copying_default(attributes)
    #   condition = {key_attribute => attributes[key_attribute]}
    #   get_mutex.synchronize do
    #     @model.transaction do
    #       entity = @model.find_or_create_by(condition)
    #       entity.update_attributes(yield) if block_given?
    #       entity
    #     end
    #   end
    # end

# class ActiveRecord::Base
#   def self.normalize_by(*args)
#     @normalizer = ApiQueue::Normalizer.new(*args)
#   end

#   def self.safe_find_or_create_by(key_attribute, *attrs)
#     # attrs = ActiveSupport::HashWithIndifferentAccess.new_from_hash_copying_default(attrs)

#     condition = {key_attribute => attrs[key_attribute.to_sym]}
#     normalizer_mutex.synchronize do
#       self.transaction do
#         entity = self.find_or_create_by(key_attribute => attrs[key_attribute.to_sym])
#         entity.update_attributes(attrs) if attrs.present?
#         entity
#       end
#     end
#   end

#   private

#   def self.normalizer_mutex
#     @safe_find_or_create_mutex ||= Mutex.new
#   end
# end
# rubocop:enable all