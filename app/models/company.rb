class Company < ActiveRecord::Base
  has_many :funding_rounds
  
  def to_json
    return {id: id, name: name, permalink:permalink, category: category, investors: investors.to_json}
  end
  
  
end
