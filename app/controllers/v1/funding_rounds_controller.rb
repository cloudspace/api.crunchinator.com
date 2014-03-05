# For the v1/funding_rounds endpoint
class V1::FundingRoundsController < ApplicationController

  # include funding round and investor information
  def index
    @funding_rounds = FundingRound.includes(:investments).legit.funded

    @status = 200
    render json: @funding_rounds, status: @status, each_serializer: V1::FundingRounds::FundingRoundSerializer
  end
end
