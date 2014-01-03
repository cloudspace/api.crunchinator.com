class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  belongs_to :funding_round

  # Investors who are associated with the passed in companies
  # @param [Array<Company>] A list of Company instances
  scope :associated_with_companies, lambda { |companies| joins(:funding_round).where("funding_rounds.company_id" => companies) }
  
  scope :associated_with_financial_organizations, lambda { |financial_organizations| where("investor_id IN (?) AND investor_type = ?", financial_organizations, "FinancialOrganization") }
end
