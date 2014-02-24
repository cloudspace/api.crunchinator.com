require 'spec_helper'

describe Person do
  before(:each) do
    @person = Person.new
  end

  describe 'mixins' do
    it 'should be an investor' do
      expect(Person.ancestors.select { |o| o.class == Module }).to include(Investor)
    end
  end

  describe 'associations' do
    it { expect(@person).to have_many :investments }
    it { expect(@person).to have_many :office_locations }
  end

  describe 'validations' do
    it { expect(@person).to validate_presence_of :permalink }
    it { expect(@person).to validate_uniqueness_of :permalink }
  end

  describe 'fields' do
    it { expect(@person).to respond_to :firstname }
    it { expect(@person).to respond_to :lastname }
    it { expect(@person).to respond_to :permalink }
  end

  describe 'scopes' do
  end

  describe 'instance methods' do
    before(:each) do
      @person = Person.new
    end

    describe 'name' do
      it 'should return the first and last name' do
        @person.firstname = 'Jeremiah'
        @person.lastname = 'Hemphill'
        expect(@person.name).to eql('Jeremiah Hemphill')
      end

      it 'should return the #{LastName} if they only have a lastname' do
        @person.lastname = 'Hemphill'
        expect(@person.name).to eql('Hemphill')
      end

      it 'should return the #{FirstName} if they only have a firstname' do
        @person.firstname = 'Jeremiah'
        expect(@person.name).to eql('Jeremiah')
      end

      it 'should return Unknown Name if the first and last names aren\'t set' do
        expect(@person.name).to eql('Unknown Name')
      end
    end
  end
end
