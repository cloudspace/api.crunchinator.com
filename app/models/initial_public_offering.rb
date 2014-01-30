# An IPO for a company
class InitialPublicOffering < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true
end
