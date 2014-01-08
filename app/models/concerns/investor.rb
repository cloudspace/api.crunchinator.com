# Mixin for investments in funding rounds
module Investor
  extend ActiveSupport::Concern

  # global unique id for frontend use
  # Two investors can share an id if they are for different classes
  # This is a duplicate of Investment.investor_guid for speed purposes
  def guid
    "#{self.class.name.underscore}-#{id}"
  end

  included do
    # placeholders scopes, should be overridden
    scope :starts_with_letter, ->(letter) { where(nil) }
    scope :starts_with_non_alpha, -> { where(nil) }
  end

  # The class methods
  # yay linter
  module ClassMethods
    # selects a scope for what letter to start with
    def starts_with(char)
      if char
        if char == '0'
          starts_with_non_alpha
        else
          starts_with_letter(char)
        end
      else
        where(nil) # don't change the query
      end
    end
  end
end
