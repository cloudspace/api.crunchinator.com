class Person < ActiveRecord::Base
  has_many :investments, as: :investor

  # Handles creating a person
  #
  # @param [Hash{String => String}] a dictionary representation of a person.
  # @return [Person] the newly created person.
  def self.create_person(parsed_person)
    # TODO: Write migration to rename 'firstname' and 'lastname' fields to match the
    # crunchbase keys
    #
    person = self.find_or_create_by_permalink(parsed_person["permalink"])
    person.update_attributes({firstname: parsed_person["first_name"], lastname: parsed_person["last_name"], permalink: parsed_person["permalink"]})
    person
  end
end
