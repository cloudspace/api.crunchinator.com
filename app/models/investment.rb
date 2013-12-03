class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  has_many :funding_round
end
