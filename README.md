# Repository Sync

This plugin was developed in order to allow integration between ArchivesSpace and the backend to our digital repository, [Digital Collections DU](https://specialcollections.du.edu). The idea is that when a user updates an ArchivesSpace record, and the record represents an archival object that has a digital form available via the repository, the repository backend can query the API calls made available via this plugin and automatically update its Elasticsearch index using the JSON response it receives.

## How it works

We have two model/exporter combinations available here, with separate API calls for each. `/repositories/:repo_id/:archival_objects/:id/repository` returns a JSON representation of selected metadata properties from both the queried Archival Object and any Digital Object attached to it and marked as its representative, which is then fed into the repository Elasticsearch index. `/repositories/:repo_id/:archival_objects/:id/repository.xml` returns a MODS XML representation of, more or less, the same metadata properties; this is derived from our [ao_mods](https://github.com/duspeccoll/ao_mods) ArchivesSpace plugin, which will soon be deprecated in favor of this one. We maintain the MODS export for the benefit of any catalogers or metadata professionals who wish to see the full MODS representation of a repository object, and to enable download of that record from the staff interface.

## Documentation

* [General model documentation](docs/model.md)
* [Documentation of JSON object mappings](docs/repository_model.md)
* [Documentation of MODS XML mappings](docs/repository_mods_model.md)
