class FundingRound < ActiveRecord::Base
  belongs_to :company
  has_many :investments

  validates :crunchbase_id, uniqueness: true, presence: true

  scope :valid, lambda { joins(:company).where('funding_rounds.company_id' => Company.valid.pluck(:id)).references(:funding_rounds) }

  # Funding rounds with some amount of USD raised
  scope :funded, lambda { where("funding_rounds.raised_currency_code = 'USD' AND funding_rounds.raw_raised_amount is not null AND funding_rounds.raw_raised_amount > 0")}

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
