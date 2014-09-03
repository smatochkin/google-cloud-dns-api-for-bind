#
# Generate common responses compliant with
#  https://developers.google.com/cloud-dns/api/v1beta1/
#
module ResponseHelper
  
  def project_not_found!(project_name)
    halt! 403, "Unknown project #{project_name}"
  end

  def zone_not_found!(zone_name)
    halt! 404, "The 'parameters.managedZone' resource named '#{zone_name}' does not exist."
  end
  
  def halt!(code, message)
    halt code, {
      :error => {
        :errors => [
          {
            :domain => "global",
            :reason => "invalid",
            :message => message
          }
        ],
        :code => code,
        :message => message
      }
    }.to_json
  end

end