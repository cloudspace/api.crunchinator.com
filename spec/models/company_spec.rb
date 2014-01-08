require 'spec_helper'

describe Company do
  before(:each) do
    @company = Company.new
  end

  describe 'associations' do
    it { expect(@company).to have_many :funding_rounds }
    it { expect(@company).to have_many :investments }
    it { expect(@company).to have_many :office_locations }
    it { expect(@company).to belong_to :category }
  end

  describe 'validations' do
    it { expect(@company).to validate_presence_of :permalink }
    it { expect(@company).to validate_uniqueness_of :permalink }
    it { expect(@company).to validate_presence_of :name }
    it { expect(@company).to validate_uniqueness_of :name }
  end

  describe 'fields' do
    it { expect(@company).to respond_to :name }
    it { expect(@company).to respond_to :permalink }
    it { expect(@company).to respond_to :crunchbase_url }
    it { expect(@company).to respond_to :blog_url }
    it { expect(@company).to respond_to :blog_feed_url }
    it { expect(@company).to respond_to :twitter_username }
    it { expect(@company).to respond_to :phone_number }
    it { expect(@company).to respond_to :email_address }
    it { expect(@company).to respond_to :description }
    it { expect(@company).to respond_to :number_of_employees }
    it { expect(@company).to respond_to :overview }
    it { expect(@company).to respond_to :homepage_url }
    it { expect(@company).to respond_to :number_of_employees }
    it { expect(@company).to respond_to :founded_year }
    it { expect(@company).to respond_to :founded_month }
    it { expect(@company).to respond_to :founded_day }
    it { expect(@company).to respond_to :deadpooled_year }
    it { expect(@company).to respond_to :deadpooled_month }
    it { expect(@company).to respond_to :deadpooled_url }
    it { expect(@company).to respond_to :tag_list }
    it { expect(@company).to respond_to :alias_list }
    it { expect(@company).to respond_to :deadpooled_day }
    it { expect(@company).to respond_to :category_id }
  end

  describe 'scopes' do
    describe 'categorized' do
      before(:each) do
        @with_category = FactoryGirl.create(:company)
        @without_category = FactoryGirl.create(:company, category: nil)
      end
      it 'should include companies with a category' do
        expect(Company.categorized).to include(@with_category)
      end
      it 'should not include companies without a category' do
        expect(Company.categorized).not_to include(@without_category)
      end
    end

    describe 'funded' do
      it 'should return a company that has a funding round with a raised amount' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:funding_round, company: company)
        expect(Company.funded).to include(company)
      end

      it 'should not return a company that has a funding round with no raised amount' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:funding_round, company: company, raw_raised_amount: '0')
        expect(Company.funded).not_to include(company)
      end
    end

    # unfunded only works if there is already at least one funded company
    describe 'unfunded' do
      before(:each) do
        funded_company = FactoryGirl.create(:company)
        FactoryGirl.create(:funding_round, company: funded_company)
      end

      it 'should not return a funded company' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:funding_round, company: company)
        expect(Company.unfunded).not_to include(company)
      end

      it 'should return an unfunded company' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:funding_round, company: company, raw_raised_amount: '0')
        expect(Company.unfunded).to include(company)
      end
    end

    describe 'geolocated' do
      it 'should include companies with a geolocated headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company)
        expect(Company.geolocated).to include(company)
      end
      it 'should not inclue a company without a geolocated headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:office_location , tenant: company)
        expect(Company.geolocated).not_to include(company)
      end
    end

    # requires at least one geolocated company to work
    describe 'unlocated' do
      before(:each) do
        geolocated_company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: geolocated_company)
      end

      it 'should include companies without a headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:office_location , tenant: company)
        expect(Company.unlocated).to include(company)
      end

      it 'should not include companies with a headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company)
        expect(Company.unlocated).not_to include(company)
      end
    end

    describe 'american'  do
      it 'should include companies with an american headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company)
        expect(Company.american).to include(company)
      end

      it 'should not include companies with an outside headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company, country_code: 'Canada')
        expect(Company.american).not_to include(company)
      end
    end

    describe 'valid' do
      it 'should return companies with a category, successful funding round, and US headquarters' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company)
        FactoryGirl.create(:funding_round, company: company)
        expect(Company.valid).to include(company)
      end
    end

    describe 'invalid' do
      it 'should not include valid companies' do
        company = FactoryGirl.create(:company)
        FactoryGirl.create(:headquarters, tenant: company)
        expect(Company.invalid).not_to include(company)
      end
    end

    describe 'non_alpha' do
      it 'should return companies whose name starts with a number' do
        included = FactoryGirl.create(:company, name: '#Hashtag')
        expect(Company.non_alpha).to include(included)
      end

      it 'should return companies whose name starts with a symbol' do
        included = FactoryGirl.create(:company, name: '1st')
        expect(Company.non_alpha).to include(included)
      end

      it 'should not return companies whose name starts with a letter' do
        excluded = FactoryGirl.create(:company, name: 'Albert\'s Apples')
        expect(Company.non_alpha).not_to include(excluded)
      end
    end

    describe 'starts_with' do
      before(:each) do
        @included = FactoryGirl.create(:company, name: 'Albert\'s Apples')
      end

      it 'should return companies whose name starts with the specified character' do
        expect(Company.starts_with('A')).to include(@included)
      end

      it 'should not exclude companies due to capitalization' do
        expect(Company.starts_with('a')).to include(@included)
      end

      it 'should not return companies whose name does not start with the specified character' do
        excluded = FactoryGirl.create(:company, name: 'Pete\'s Pears')
        expect(Company.starts_with('a')).not_to include(excluded)
      end
    end
  end

  describe 'instance methods' do
    before(:each) do
      @company = Company.new
    end

    describe 'headquarters' do
      # this could be turned into a unit test.  Not sure how much it would be testing though
      it 'should return the headquarters' do
        company = FactoryGirl.create(:company)
        headquarters = FactoryGirl.create(:headquarters, tenant: company)
        expect(company.headquarters).to eql(headquarters)
      end
    end

    describe 'zip_code' do
      it 'should return the headquarters zip code' do
        headquarters = OfficeLocation.new(zip_code: '12345')
        @company.stub(:headquarters).and_return(headquarters)
        expect(@company.zip_code).to eql('12345')
      end

      it 'should return a blank string if no headquarters' do
        expect(@company.zip_code).to be_blank
      end
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

    describe 'latitude' do
      it 'should be set to the headquarters latitude' do
        headquarters = OfficeLocation.new(zip_code: '12345')
        @company.stub(:headquarters).and_return(headquarters)
        expect(@company.latitude).to eql(headquarters.latitude)
      end
    end

    describe 'longitude' do
      it 'should be set to the headquarters longitude' do
        headquarters = OfficeLocation.new(zip_code: '12345')
        @company.stub(:headquarters).and_return(headquarters)
        expect(@company.latitude).to eql(headquarters.latitude)
      end
    end
  end
end
