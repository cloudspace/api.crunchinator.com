require 'spec_helper'

describe Investor do
  describe 'instance methods' do
    describe 'guid' do
      it 'should include the class name and id, see the investor method' do
        person = Person.new(id: 1)
        expect(person.guid).to eql('person-1')
      end

      it 'should match the investment guid' do
        investor = Person.new(id: 1)
        investment = Investment.new(investor: investor)
        expect(investment.investor_guid).to eql(investor.guid)
      end
    end
  end
end
