# An IPO for a company
class InitialPublicOffering < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true

  # Returns the valuation amount if present and in USD, else nil
  #
  # @return [FixNum, nil] the valuation produced by the ipo, in USD, or nil
  def usd_valuation
    valuation_amount if valuation_currency_code.try(:upcase) == 'USD'
  end
end
