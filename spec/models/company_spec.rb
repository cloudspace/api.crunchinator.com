require 'spec_helper'

describe Company do
  describe "associations" do
    before(:each) do
      @company = Company.new
    end
    subject { @company }
  
    it { should have_many :funding_rounds }
    it { should have_many :investments }
    it { should have_many :office_locations }
    it { should belong_to :category }
  end
  
  describe "validations" do
    it { should validate_presence_of :permalink }
    it { should validate_uniqueness_of :permalink }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end
  
  describe "fields" do
    it { should respond_to :name }
    it { should respond_to :permalink }
    it { should respond_to :crunchbase_url}
    it { should respond_to :blog_url }
    it { should respond_to :blog_feed_url }
    it { should respond_to :twitter_username }
    it { should respond_to :phone_number }
    it { should respond_to :email_address }
    it { should respond_to :description }
    it { should respond_to :number_of_employees }
    it { should respond_to :overview }  
    it { should respond_to :homepage_url }  
    it { should respond_to :number_of_employees }
    it { should respond_to :founded_year }
    it { should respond_to :founded_month }
    it { should respond_to :founded_day }  
    it { should respond_to :deadpooled_year }
    it { should respond_to :deadpooled_month }
    it { should respond_to :deadpooled_url }
    it { should respond_to :tag_list }  
    it { should respond_to :alias_list }
    it { should respond_to :deadpooled_day }
    it { should respond_to :category_id }
  end

  describe 'scopes' do
    describe "categorized" do
      it "needs tests"
    end

    describe "funded" do
      it "needs tests"
    end

    describe "unfunded" do
      it "needs tests"
    end
  
    describe "geolocated" do
      it "needs tests"
    end

    describe "unlocated" do
      it "needs tests"
    end

    describe "american"  do
      it "needs tests"
      it "needs test for the longitude constants"
    end

    describe "valid" do
      it "needs tests"
    end

    describe "invalid" do
      it "needs tests"
    end

    describe "non_alpha" do
      it "needs tests"
    end
  end

  describe 'class methods' do
    describe "start_with" do
      it "needs tests"
    end
  end

  describe 'instance methods' do
    before(:each) do
      @company = Company.new
    end

    describe "headquarters" do
      it "needs tests"
    end

    describe "zip_code" do
      it "needs tests"
    end

    describe 'total_funding' do
      it 'should return 0 if there are no funding rounds' do
        expect(@company.total_funding).to eql(0)
      end

      it 'should return the sum of the funding rounds raised amount' do
        # wow rails, you so great
        funding_round1 = FundingRound.new(raw_raised_amount: BigDecimal.new('1000'), raised_currency_code: 'USD')
        funding_round2 = FundingRound.new(raw_raised_amount: BigDecimal.new('2000'), raised_currency_code: 'USD')

        @company.stub(:funding_rounds).and_return([funding_round1, funding_round2])
        expect(@company.total_funding).to eql(BigDecimal.new('3000'))
      end
    end

    describe "latitude" do
      it "needs tests"
    end

    describe "longitude" do
      it "needs tests"
    end

    describe "set_lat_long_cache" do
      it "needs tests"
    end
  end
end
