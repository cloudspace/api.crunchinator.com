class CrunchbaseFetchCompany < TrackableTasks::Base
  def initialize(company, log_level = :notice)
    @company = company
    super log_level
  end

  def run
    company = {
      "permalink" => "23andme"
    }
    is_service = false
    Company.process_company(company,is_service)
  end
end
