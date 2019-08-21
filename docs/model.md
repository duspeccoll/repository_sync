# Repository/ArchivesSpace Integration Model

## Digital Repository Definitions

The Digital Repository follows the [Portland Common Data Model](https://github.com/duraspace/pcdm/wiki) (PCDM) in modeling digital assets.

In the Digital Repository, an *object* is a single resource, in any format, representing intellectual content as determined by its author or creator. An object consists of one or more files, and may be contained by one collection. A collection is defined as a set of one or more objects, related together by a curator according to one or more shared traits, such as shared provenance, form or genre, or arrangement around a theme.

In the University of Denver implementation of ArchivesSpace, the three PCDM data models are arranged as follows:

* **Collections** may be represented as either Resources or Archival Objects.

    In cases when the traits defining a Digital Repository collection are the same as those defining its archival collection, i.e. that they originated from the same record-creating body according to the same provenance, or that they were curated according to a theme by an archivist or a donor, an ArchivesSpace resource will correspond to the Digital Repository collection.

    However, in cases where the digital collection is a component of a larger archival collection that has not been fully digitized, the Digital Repository collection may be represented in ArchivesSpace as a series or subseries of a larger collection, i.e. as an Archival Object.

* **Objects** are represented as Archival Objects; specifically, they are represented as Item records belonging to a Resource or a Resource Component (such as a series, box, or folder). Each Item will be represented in ArchivesSpace by a Digital Object; the Digital Object will contain technical information about the Object, such as its URI and resource type.

* **Files** are represented as Digital Object Components. Each Digital Object in ArchivesSpace consists of one or more Component records, representing the file and its technical information. This technical information includes file formats, file size, and other uniquely identifying information about the file, such as a caption (for display in the Digital Repository) or a Kaltura unique identifier (for integration with audiovisual content in [DU MediaSpace](https://mediaspace.du.edu/)).

## Model Definitions

In the terms definitions below, references to the following ArchivesSpace data models are used:

* **Archival Object:** The resource component record representing the digital material, where its descriptive metadata are recorded.
* **Digital Object:** The digital object record representing the digital material, where its handle and resource type are recorded.
* **Digital Object Component:** The file-level metadata representing the digital material's constituent files, represented in ArchivesSpace as children of the Digital Object representing the Archival Object.

## Metadata Specifications

The Repository/ArchivesSpace integration serializes metadata about digital objects in both proprietary JSON (that is, JSON that is indexed directly by Elasticsearch and that is unique to the Archives @ DU Catalog) and in [MODS XML](http://www.loc.gov/standards/mods). While the former allows for direct integration of ArchivesSpace metadata with the repository, the latter allows for standards compliance and for ease of migration to another repository application, should the need arise.

More information:

* [Mappings for Digital Repository JSON Objects](repository_model.md)
* [Mappings for MODS XML](repository_mods_model.md)
