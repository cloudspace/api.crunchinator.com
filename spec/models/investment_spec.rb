require 'spec_helper'

describe Investment do
  describe "associations" do
    before(:each) do
      @investment = Investment.new
    end
    subject { @investment }
    
    it { should belong_to :investor }
    it { should belong_to :funding_round }
  end

  describe 'class methods' do
    describe 'create investor' do
      it 'should create a new Investment'
      it 'should associate an Investment with an Investor'
      it 'should return a new Investment'
    end
  end

end
