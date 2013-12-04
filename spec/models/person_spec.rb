require 'spec_helper'

describe Person do

  describe "associations" do
    before(:each) do
      @person = Person.new
    end
    subject { @person }
    
    it { should have_many :investments }
  end

  describe 'class methods' do
    describe 'create person' do
      it 'should create a new Person'
      it 'should return a newly created Person'
    end
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

      it 'should return Unknown Name if the first and last names aren\'t set' do
        expect(@person.name).to eql('Unknown Name')
      end
    end
  end
end
