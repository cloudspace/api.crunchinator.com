class Investment < ActiveRecord::Base
  belongs_to :investor, polymorphic: true
  belongs_to :funding_round

  # Handles creating an Investment relationship
  #
  # @param [Person, Company] a representation of an Investor
  # @param [Integer] the funding round id
  # @param [Company] the company that is being invested into
  # @return [Investment] a representation of the Investment relationship
  #
  def self.create_investor(investor, funding_round_id, company)
    self.create({
      investor_id: investor.id, 
      investor_type: investor.class.to_s,
      funding_round_id: funding_round_id
    })
  end
end
