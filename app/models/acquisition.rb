# One company acquiring another company
class Acquisition < ActiveRecord::Base
  belongs_to :acquiring_company, class_name: 'Company'
  belongs_to :acquired_company, class_name: 'Company'

  validates :acquired_company, presence: true
  validates :acquiring_company, presence: true

  def usd?
    price_currency_code == 'USD'
  end

  alias_attribute :date, :acquired_on
  alias_attribute :company_id, :acquiring_company_id

  def amount
    usd? ? price_amount.to_i : 0
  end
end
