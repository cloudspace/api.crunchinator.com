class Company < ActiveRecord::Base
  has_many :funding_rounds
  has_many :investments, as: :investor
  
  def to_json
    return {id: id, name: name, permalink:permalink, category: category, investors: investors.to_json}
  end
end
