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
    has_many :investments, as: :investor, dependent: :destroy
    has_many :outgoing_funding_rounds, through: :investments, source: :funding_round
    has_many :invested_companies, -> { distinct }, through: :outgoing_funding_rounds, source: :company
    has_many :invested_categories, -> { distinct }, through: :invested_companies, source: :category
  end

end
