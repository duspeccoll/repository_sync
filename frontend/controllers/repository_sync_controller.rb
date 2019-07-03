class RepositorySyncController < ApplicationController

  set_access_control "view_repository" => [:index, :search, :download]

  include ExportHelper

  def index
  end

  def search
    if params['item'].nil?
      flash[:error] = "No item selected"
      redirect_to :action => :index
    else
      params['ref'] = params['item']['ref'] if params['ref'].nil?
      @results = do_search(params)
    end
  end

  def download
    download_export("/repositories/#{JSONModel::repository}/archival_objects/#{params[:id]}/repository.xml")
  end

  private

  def do_search(params)
    ref = params['ref']
    json = JSONModel::HTTP::get_json(ref)

    results = {
			'title' => json['title'],
			'id' => json['component_id'],
			'ref' => ref
		}

    json_uri = URI("#{JSONModel::HTTP.backend_url}#{ref}/repository")
    json_response = HTTPRequest.new.get(json_uri)
    if json_response.is_a?(Net::HTTPSuccess)
      obj = JSON.parse(json_response.body)
      results['json'] = JSON.pretty_generate(obj)
    else
      results['json'] = "An error occurred while fetching JSON."
    end

    mods_uri = URI("#{JSONModel::HTTP.backend_url}#{ref}/repository.xml")
    mods_response = HTTPRequest.new.get(mods_uri)
    if mods_response.is_a?(Net::HTTPSuccess)
      xml = Nokogiri::XML(mods_response.body,&:noblanks)
      mods = xml.at_css('mods')
      results['mods'] = mods.to_xml(indent: 2)
    else
      results['mods'] = "An error occurred while fetching MODS XML."
    end

    results
  end

end
