require 'spec_helper'

describe ApiQueue::Parser::Base do
  describe "class methods" do
    describe "inherited" do
      it "should create a threadsafe mutexes hash when subclassed" do
        class Foo < ApiQueue::Parser::Base; end
        Foo.instance_variables.should include(:@mutexes)
      end
    end
    describe "safe_find_or_create_by and associated mutex methods" do
      describe "get_mutex" do
      end

      describe "safe_find_or_create_by" do
      end
    end

    describe "prcoess_entity" do
    end

    describe "model creation methods" do
      describe "create_company" do
      end

      describe "create_office_location" do
      end

      describe "create_category" do
      end

      describe "create_financial_org" do
      end

      describe "create_funding_round" do
      end

      describe "create_investment" do
      end

      describe "create_person" do
      end
    end
  end
end
