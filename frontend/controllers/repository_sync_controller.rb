class RepositorySyncController < ExportsController

  set_access_control "view_repository" => [:download]

  include ExportHelper

  def download
    download_export("/repositories/#{JSONModel::repository}/archival_objects/#{params[:id]}/repository.xml")
  end

end
