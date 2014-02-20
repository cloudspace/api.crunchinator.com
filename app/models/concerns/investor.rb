# Mixin for investments in funding rounds
module Investor
  extend ActiveSupport::Concern

  # global unique id for frontend use
  # Two investors can share an id if they are for different classes
  # This is a duplicate of Investment.investor_guid for speed purposes
  def guid
    "#{self.class.name.underscore}-#{id}"
  end
end
