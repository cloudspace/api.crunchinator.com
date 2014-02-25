# One company acquiring another company
class Acquisition < ActiveRecord::Base
  belongs_to :acquiring_company, class_name: 'Company'
  belongs_to :acquired_company, class_name: 'Company'

  validates :acquired_company, presence: true
  validates :acquiring_company, presence: true

  def usd?
    price_currency_code == 'USD'
  end

  def date
    acquired_on
  end

  def company_id
    acquiring_company_id
  end

  def amount
    if usd?
      price_amount.to_i
    else
      0
    end
  end
end
