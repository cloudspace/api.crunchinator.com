class FundingRound < ActiveRecord::Base
  belongs_to :company
  has_many :investments

  validates :crunchbase_id, :uniqueness => true

  # Handles creating funding rounds for a company
  #
  # @param [Hash{String => String}] a hash representation of a funding round.
  # @param [Company] the company to associate the funding round with.
  # @return [FundingRound] the created funding round.
  def self.create_funding_round(parsed_funding_round, company)
    dup = parsed_funding_round.clone
    dup.delete_if {|key| !self.column_names.include?(key)}
    dup["raw_raised_amount"] = dup.delete("raised_amount")
    dup["crunchbase_id"] = dup.delete("id")
    dup[:company_id] = company.id
    self.create(dup)
  end

  # Returns the raised amount if in USD, else 0 (expressed as a BigDecimal)
  #
  # @return [BigDecimal] the raised amount.
  def raised_amount
    raised_currency_code && raised_currency_code.upcase == "USD" && raw_raised_amount ? raw_raised_amount : BigDecimal.new('0')
  end

  # temporary method. Should be replaced by a database change soon (JH 12-4-2013)
  # also delete the test
  def funded_on
    if(funded_year && funded_month && funded_day)
      Time.new(funded_year, funded_month, funded_day).to_date
    end
  end
end
