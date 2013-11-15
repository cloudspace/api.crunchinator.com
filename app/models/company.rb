class Company < ActiveRecord::Base
  
  def to_json
    return {id: id, name: name, permalink:permalink, category: category, investors: investors.to_json}
  end
  
  
end
