class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/repositories/:repo_id/archival_objects/:id/repository')
    .description("Get a Repository JSON representation of an Archival Object")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "OK"]) \
  do
    obj = resolve_references(ArchivalObject.to_jsonmodel(params[:id]), ['linked_agents', 'subjects', 'digital_object'])
    json = ASpaceExport.model(:repository).from_archival_object(JSONModel(:archival_object).new(obj))

    json_response(ASpaceExport::serialize(json))
  end

  Endpoint.get('/repositories/:repo_id/archival_objects/:id/repository.xml')
    .description("Get a MODS XML representation of an Archival Object")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "OK"]) \
  do
    obj = resolve_references(ArchivalObject.to_jsonmodel(params[:id]), ['linked_agents', 'subjects', 'digital_object'])
    mods = ASpaceExport.model(:repository_mods).from_archival_object(JSONModel(:archival_object).new(obj))

    xml_response(ASpaceExport::serialize(mods))
  end

  Endpoint.get('/repositories/:repo_id/archival_objects/:id/repository.:fmt/metadata')
    .description("Get metadata for a MODS representation of an Archival Object")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "The export metadata"]) \
  do
    json_response({"filename" => "#{ArchivalObject[params[:id]].component_id}_mods.xml".gsub(/\s+/, '_'), "mimetype" => "application/xml"})
  end

  Endpoint.get('/repositories/:repo_id/resources/:id/repository')
    .description("Get a Repository JSON representation of a Resource")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "OK"]) \
  do
    obj = resolve_references(Resource.to_jsonmodel(params[:id]), ['linked_agents', 'subjects', 'digital_object'])
    json = ASpaceExport.model(:repository).from_resource(JSONModel(:resource).new(obj))

    json_response(ASpaceExport::serialize(json))
  end

end
