require 'spec_helper'

describe Category do
  describe "associations" do
    before(:each) do
      @category = Category.new
    end
    subject { @category }
  
    it { should have_many :companies }
  end
end
