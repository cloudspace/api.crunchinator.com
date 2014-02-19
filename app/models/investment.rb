# An investment in a company through a funding round by an investor
# Used to determine how much funding companies have
# and which investors have invested where
class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  belongs_to :funding_round

  scope :valid, lambda {
    joins(funding_round: :company).merge(FundingRound.valid)
  }

  # Investors who are associated with the passed in companies
  # @param [Array<Company>] A list of Company instances
  scope :associated_with_companies, lambda { |companies|
    joins(:funding_round)
    .where(funding_rounds: { company_id: companies })
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
