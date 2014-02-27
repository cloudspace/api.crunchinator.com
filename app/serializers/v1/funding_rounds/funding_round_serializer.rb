# Funding rounds for companies on the companies index endpoint
class V1::FundingRounds::FundingRoundSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :round_code, :raised_amount, :funded_on, :investor_ids

  def round_code
    @object.round_code.try(:titleize).try(:gsub, 'Ipo', 'IPO')
  end

  def funded_on
    @object.funded_on.try(:strftime, '%-m/%-d/%Y')
  end

  def investor_ids
    @object.investments.map(&:investor_guid)
  end
end
