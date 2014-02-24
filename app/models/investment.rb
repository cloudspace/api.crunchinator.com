# An investment in a company through a funding round by an investor
# Used to determine how much funding companies have
# and which investors have invested where
class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  belongs_to :funding_round

  scope :legit, lambda {
    joins(funding_round: :company).merge(FundingRound.legit)
  }

  scope :associated_with_financial_organizations, lambda { |financial_organizations|
    where(investor_id: financial_organizations, investor_type: 'FinancialOrganization')
  }

  # Investments that are invested in by the specified investor type
  scope :by_investor_class, ->(klass) { where(investor_type: klass.name) }

  # guid for investors in the front end
  #
  # This should match Investor.guid.  It is duplicated here to save a query when necessary
  def investor_guid
    "#{investor_type.underscore}-#{investor_id}"
  end
end
