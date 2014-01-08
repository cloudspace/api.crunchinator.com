require 'spec_helper'

describe Person do
  before(:each) do
    @person = Person.new
  end

  describe "associations" do
    it { expect(@person).to have_many :investments }
    it { expect(@person).to have_many :office_locations }
  end
  
  describe "validations" do
    it { expect(@person).to validate_presence_of :permalink }
    it { expect(@person).to validate_uniqueness_of :permalink }
  end
  
  describe "fields" do
    it { expect(@person).to respond_to :firstname }
    it { expect(@person).to respond_to :lastname }
    it { expect(@person).to respond_to :permalink}
  end

  describe "scopes" do
    describe "non_alpha" do
      it "should return people whose name starts with a number" do
        included = FactoryGirl.create(:person, :firstname => "#Hashtag")
        expect(Person.non_alpha).to include(included)
      end

      it "should return people whose name starts with a symbol" do
        included = FactoryGirl.create(:person, :firstname => "1st")
        expect(Person.non_alpha).to include(included)
      end

      it "should not return people whose name starts with a letter" do
        excluded = FactoryGirl.create(:person, :firstname => "Albert", :lastname => "Apples")
        expect(Person.non_alpha).not_to include(excluded)
      end
    end

    describe "starts_with" do
      before(:each) do
        @included = FactoryGirl.create(:person, :firstname => "Albert", :lastname =>  "Apples")
      end

      it "should return people whose name starts with the specified character" do
        expect(Person.starts_with("A")).to include(@included)
      end

      it "should not exclude people due to capitalization" do
        expect(Person.starts_with("a")).to include(@included)
      end

      it "should not return people whose name does not start with the specified character" do
        excluded = FactoryGirl.create(:person, :firstname => "Pete", :lastname => "Pears")
        expect(Person.starts_with("a")).not_to include(excluded)
      end
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
