# A series of investments by investors on companies
class FundingRound < ActiveRecord::Base
  belongs_to :company
  has_many :investments

  validates :crunchbase_id, uniqueness: true, presence: true

  # all funding rounds attached to the given list of companies
  scope :for_companies, lambda { |company_ids|
    joins(:company)
    .where(company_id: company_ids)
  }

  # funding rounds attached to a valid company
  scope :valid, lambda {
    where('funding_rounds.company_id' => Company.valid.pluck(:id))
  }

  # Funding rounds with some amount of USD raised
  scope :funded, lambda {
    where(raised_currency_code: 'USD')
    .where('funding_rounds.raw_raised_amount is not null AND funding_rounds.raw_raised_amount > 0')
  }

  # Returns the raised amount if in USD, else 0 (expressed as a BigDecimal)
  #
  # @return [BigDecimal] the raised amount.
  def raised_amount
    if raised_currency_code && raised_currency_code.upcase == 'USD' && raw_raised_amount
      raw_raised_amount
    else
      BigDecimal.new('0')
    end
  end

  # temporary method. Should be replaced by a database change soon (JH 12-4-2013)
  # also delete the test
  def funded_on
    Time.new(funded_year, funded_month, funded_day).to_date if funded_year && funded_month && funded_day
  end
end
