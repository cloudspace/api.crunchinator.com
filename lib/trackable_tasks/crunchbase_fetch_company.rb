class CrunchbaseFetchCompany < TrackableTasks::Base
  def initialize(company, log_level = :notice)
    @company = company
    super log_level
  end

  def run
    company = {
      "permalink" => @company
    }
    is_service = false
    Company.process_company(company,is_service)
  end
end
