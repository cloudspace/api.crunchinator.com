class RemovePublicRelationCategory < ActiveRecord::Migration
  def change
    public_relation = Category.find_by(name: 'public_relation')
    public_relations = Category.find_by(name: 'public_relations')
    if public_relation && public_relations
      Company.where(category_id: public_relation.id).update_all(category_id: public_relations.id)
    end
    public_relation.try(:destroy)
  end
end
