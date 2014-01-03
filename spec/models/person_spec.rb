require 'spec_helper'

describe Person do

  describe "associations" do
    before(:each) do
      @person = Person.new
    end
    subject { @person }
    
    it { should have_many :investments }
    it { should have_many :office_locations }
  end
  
  describe "validations" do
    it { should validate_presence_of :permalink }
    it { should validate_uniqueness_of :permalink }
  end
  
  describe "fields" do
    it { should respond_to :firstname }
    it { should respond_to :lastname }
    it { should respond_to :permalink}
  end

  describe "scopes" do
    describe "non_alpha" do
      it "needs tests"
    end
  end

  describe 'class methods' do
    describe "starts_with" do
      it "needs tests"
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
