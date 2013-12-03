class FundingRound < ActiveRecord::Base
  belongs_to :company
  has_many :investments, as: :investor
end
