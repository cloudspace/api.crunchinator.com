class FundingRound < ActiveRecord::Base
  belongs_to :company
  has_many :investments

  # Handles creating funding rounds for a company
  #
  # @param [Hash{String => String}] a dictionary representation of a funding round.
  # @param [Company] the company to associate the funding round with.
  # @return [FundingRound] the created funding round.
  def self.create_funding_round(parsed_funding_round, company)
    dup = parsed_funding_round.clone
    dup.delete_if {|key| !self.column_names.include? key }
    dup[:company_id] = company.id
    self.create(dup)
  end
end
