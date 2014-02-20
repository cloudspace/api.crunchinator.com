# One company acquiring another company
class Acquisition < ActiveRecord::Base
  belongs_to :acquiring_company, class_name: 'Company'
  belongs_to :acquired_company, class_name: 'Company'

  validates :acquired_company, presence: true
  validates :acquiring_company, presence: true
end
