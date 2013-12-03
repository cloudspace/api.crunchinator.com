class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  belongs_to :funding_round
end
