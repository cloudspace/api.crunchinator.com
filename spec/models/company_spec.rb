require 'spec_helper'

describe Company do
  before(:each) do
    @company = Company.new
  end

  describe 'mixins' do
    it 'should be an investor' do
      expect(Company.ancestors.select { |o| o.class == Module }).to include(Investor)
    end
  end

  describe 'associations' do
    it { expect(@company).to have_many :funding_rounds }
    it { expect(@company).to have_many :investments }
    it { expect(@company).to have_many :office_locations }
    it { expect(@company).to belong_to :category }
    it { expect(@company).to have_many :acquisitions }
    it { expect(@company).to have_many :acquired_by }
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
    it { expect(@company).to respond_to :deadpooled_on }
    it { expect(@company).to respond_to :tag_list }
    it { expect(@company).to respond_to :alias_list }
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

    describe 'starts_with_non_alpha' do
      it 'should return companies whose name starts with a number' do
        included = FactoryGirl.create(:company, name: '#Hashtag')
        expect(Company.starts_with_non_alpha).to include(included)
      end

      it 'should return companies whose name starts with a symbol' do
        included = FactoryGirl.create(:company, name: '1st')
        expect(Company.starts_with_non_alpha).to include(included)
      end

      it 'should not return companies whose name starts with a letter' do
        excluded = FactoryGirl.create(:company, name: 'Albert\'s Apples')
        expect(Company.starts_with_non_alpha).not_to include(excluded)
      end
    end

    describe 'starts_with_letter' do
      before(:each) do
        @included = FactoryGirl.create(:company, name: 'Albert\'s Apples')
      end

      it 'should return companies whose name starts with the specified character' do
        expect(Company.starts_with_letter('A')).to include(@included)
      end

      it 'should not exclude companies due to capitalization' do
        expect(Company.starts_with_letter('a')).to include(@included)
      end

      it 'should not return companies whose name does not start with the specified character' do
        excluded = FactoryGirl.create(:company, name: 'Pete\'s Pears')
        expect(Company.starts_with_letter('a')).not_to include(excluded)
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

    describe 'most_recent_acquired_on' do
      it 'should return the most recent acquired_on' do
        a1 = Acquisition.new(acquired_company: @company, acquired_on: 1.day.ago)
        a2 = Acquisition.new(acquired_company: @company, acquired_on: 2.days.ago)
        @company.stub(:acquired_by).and_return([a1, a2])

        expect(@company.most_recent_acquired_on).to eq(a1.acquired_on)
      end
    end

    describe 'most_recent_acquired_by_id' do
      it 'should return the most recent acquiring compnay id' do
        a1 = Acquisition.new(acquired_company: @company, acquired_on: 1.day.ago, acquiring_company_id: 1)
        a2 = Acquisition.new(acquired_company: @company, acquired_on: 2.days.ago, acquiring_company_id: 2)
        @company.stub(:acquired_by).and_return([a1, a2])

        expect(@company.most_recent_acquired_by).to eq(a1.acquiring_company_id)
      end
    end

    describe 'total_funding' do
      it 'should return 0 if there are no funding rounds' do
        expect(@company.total_funding).to eql(0)
      end

      it 'should return the sum of the funding rounds raised amount, expressed as a FixNum' do
        # wow rails, you so great
        funding_round1 = FundingRound.new(raw_raised_amount: BigDecimal.new('1000'), raised_currency_code: 'USD')
        funding_round2 = FundingRound.new(raw_raised_amount: BigDecimal.new('2000'), raised_currency_code: 'USD')

        @company.stub(:funding_rounds).and_return([funding_round1, funding_round2])
        expect(@company.total_funding).to eql(3000)
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
