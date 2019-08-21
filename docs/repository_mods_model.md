# Mappings for MODS XML

The MODS export is defined in `backend/model`. [repository_mods_model.rb](backend/model/repository_mods_model.rb) defines the metadata conversion from the ArchivesSpace data model to the MODS data model, and [repository_mods_exporter.rb](backend/model/repository_mods_exporter.rb) serializes the resulting object as MODS XML.

## Title

The name given to the resource by its creator or a curator. Title for the repository object is constructed using the ArchivesSpace item title and, if present, the creation date, e.g. "[Cane Head, circa 1865.](https://duarchives.coalliance.org/repositories/2/archival_objects/68813)"

**MODS XML:** `titleInfo/title`  
**ArchivesSpace:** Archival Object: Title

## Local Identifier

A unique string describing the resource in a larger context, such as the collection or repository to which it belongs.

**MODS XML:** `identifier[@type="local"]`  
**ArchivesSpace:** Archival Object: Component ID

## Resource Type

The high-level form taken by the resource. Uses the [MODS Type of Resource vocabulary](http://www.loc.gov/standards/mods/userguide/typeofresource.html).

**MODS XML:** `typeOfResource`  
**ArchivesSpace:** Digital Object: Digital Object Type

## Language

The language in which the resource is expressed. Includes text expression and ISO639-2 code. If multiple language are present, coded as 'multiple languages' with a Language of Materials note.

Language is set up in the JSON object as an array, but because ArchivesSpace does not currently support including more than one entry in the Language field, this array will never have more than one language in it.

**MODS XML:** `language/languageTerm`  
**ArchivesSpace:** Archival Object: Language

## Dates

Dates associated with the lifecycle of the resource. Specific date types are dictated by the label assigned to them in ArchivesSpace.

If a human-readable date expression is provided in ArchivesSpace, it is sent to the MODS XML serializer. Otherwise, the serializer receives the begin and end dates provided, with attributes indicating the date format (w3cdtf) and whether it is the beginning or end date of the range provided.

If a date certainty is provided in the resource's Date sub-record form, it will be included as an attribute in the date field. Value options for this attribute include "approximate," "inferred," or "questionable."

**MODS XML:** Varies by date type  
**ArchivesSpace:** Archival Object: Dates

Specific date types in use in the repository are documented below.

### Date Created

The date on which the resource was originally created. If digitized, this date refers to the analog version; if born-digital, this date refers to the original digital version.

**MODS XML:** `originInfo/dateCreated`  
**ArchivesSpace:** Archival Object: Dates (with "Creation" label)

### Date Digitized

The date on which the resource was digitized, if originally realized in analog format.

**MODS XML:** `originInfo/dateCaptured`  
**ArchivesSpace:** Archival Object: Dates (with "Digitization" label)

### Copyright Date

The date on which copyright over the resource went into effect.

**MODS XML:** `originInfo/copyrightDate`  
**ArchivesSpace:** Archival Object: Dates (with "Copyright" label)

### Date Modified

The date on which the resource was modified in some way.

**MODS XML:** `originInfo/dateModified`  
**ArchivesSpace:** Archival Object: Dates (with "Modified" label)

### Date Issued

The date on which the resource was published or otherwise made available publicly, if later than or different from the creation date. In the MODS XML export, this field is a catch-all for the "Broadcast," "Issued," and "Publication" labels.

**MODS XML:** `originInfo/dateIssued`  
**ArchivesSpace:** Archival Object: Dates (with "Broadcast," "Issued," or "Publication" label)

### Other Date

Any other date label not specifically represented by the date properties above.

**MODS XML:** `originInfo/dateOther`  
**ArchivesSpace:** Archival Object: Dates (with any label not specified above)

## Extent

The quantitative measurement of the scope of the resource. May be measured as items, linear feet, or as electronic storage space (gigabytes).

Extents in the repository are constructed from the metadata provided in ArchivesSpace. The `extents` object is an array of strings of the form "[number] [extent_type] ([portion])".

**MODS XML:** `physicalDescription/extent`  
**ArchivesSpace:** Archival Object: Extent

## Extent Notes

The MODS export handles two note types -- Physical Characteristics and Technical Requirements (`phystech`) and Dimensions (`dimensions`) -- differently from the note types described below in the Notes section of this documentation. Because this information may be found in the Extent sub-record form of the item record instead of/in addition to in the Notes section of the item record, the exporter models these fields into an `extent_notes` object, which is then serialized as a `<note>` element in the resulting MODS XML document representing the item.

Details about these notes may be found below.

### Physical Details

Notes about physical characteristics of the resource, such as its coloration, general condition, and the materials with which it was made.

**MODS XML:** `note[@type='physical_description']`  
**ArchivesSpace:** Archival Object: Extent: Physical Details OR Archival Object: Note (with "phystech" type)

### Dimensions

The dimensions of the resource. Non-prescriptive; may be measured in area, in duration (hours/minutes/seconds), or in other size measurements.

**MODS XML:** `note[@type='dimensions']`  
**ArchivesSpace:** Archival Object: Extent: Dimensions OR Archival Object: Note (with "dimensions" type)

## Digital Origin

The method by which the resource came to be digitized. At Denver, Digital Origin is defined by enum_3 in the User Defined fields.

**MODS XML:** `physicalDescription/digitalOrigin`  
**ArchivesSpace:** Digital Object: MODS Digital Origin

## Subjects

A coordinated heading indicating the topical, geographic, or temporal coverage of the resource, or the form or genre taken by the resource.

Subject headings in MODS are subdivided according to the term types provided when a heading is established in ArchivesSpace. These may be topical, geographic, temporal, uniform title (i.e. the title of a work, [BIBFRAME](http://bibfra.me/vocab/lite/Work) or otherwise), or genre/form headings. A heading may have more than one coordinated term. Consult the [MODS documentation on subjects](http://www.loc.gov/standards/mods/mods-outline-3-6.html#subject) for more information.

**MODS XML:** `subject`  
**ArchivesSpace:** Archival Object: Subjects

Additional subject properties are listed below.

### Source

The source of the subject heading. Options include:

* LCSH
* Local (if the term does not exist in any of the above vocabularies)
* Provisional (if it may be in one of the above vocabularies but has not been confirmed by a Digital Collections Technician)

**MODS XML:** `subject[@authority]`  
**ArchivesSpace:** Subject: Source

### Authority ID

The URI for the subject heading, if drawn from a controlled vocabulary (indicated in the Source). Not needed if the subject heading is local.

**MODS XML:** `subject[@authorityURI]`  
**ArchivesSpace:** Subject: Authority ID

### Terms

The constituent terms of the subject heading. This is structured as an array, ordered by the coordinated term order of the ArchivesSpace subject heading; term types are included.

**ArchivesSpace:** Subject: Terms

Terms are serialized as MODS XML properties according to the term type provided in the subject heading to which they belong, as enumerated below:

* **Geographic terms** (i.e. locations): `geographic`
* **Temporal terms** (i.e. time periods or eras): `temporal`
* **Uniform titles** (i.e. titles of works): `titleInfo/title`
* **Genre/form terms** (i.e. the form or resource type to which the described resource belongs): `genre`
* **Occupation terms** (i.e. the line of work or activity represented by the resource): `occupation`
* **Topical terms** (i.e. what the resource is about, if not covered by the term types above): `topic`

Terms may be coordinated, i.e. a subject heading may contain multiple coordinated terms, such as [Music teachers -- Denver (Colo.)](https://duarchives.coalliance.org/subjects/4974). In this case, terms will serialize in the MODS XML record in the order in which the terms are situated in the ArchivesSpace subject heading.

## Names

Entities responsible for the creation or management of the resource, or who are topically covered by the resource. Named entities are managed in ArchivesSpace through the Agents data model, which is further subdivided into Person, Corporate Entity, and Family data models. They are then referenced by the resource's item record.

In ArchivesSpace items, linked agents may have a role of "Creator," "Source," or "Subject." Creator agents may be further identified through [MARC Relator Terms](https://www.loc.gov/marc/relators), such as "photographer" or "interviewee," to identify the specific role they played in the creation or management of the resource.

When the linked agent has a role of "subject," it is serialized with the other subjects using the MODS `name/namePart` convention. Otherwise it is serialized on its own.

**MODS XML:** `name`  
**ArchivesSpace:** Archival Object: Linked Agents

Additional data properties used for named entities are documented below.

### Role

The role played by the linked named entity in the creation or lifecycle of the resource. (Not provided if the role is Subject.)

**MODS XML:** `name/role/roleTerm`  
**ArchivesSpace:** Archival Object: Linked Agents: Role

### Authority

The source of the name for the linked entity. May be local, or derived from an existing vocabulary such as the Library of Congress Name Authority File or the Virtual International Authority File.

**MODS XML:** `name[@authority]`  
**ArchivesSpace:** Agent: Name: Source

### Authority ID

The Uniform Resource Identifier (URI) assigned to the named entity in the context of its authority source.

**MODS XML:** `name[@authorityURI]`  
**ArchivesSpace:** Agent: Name: Authority ID

## Notes

Descriptive statements about the resource and its context. In the repository object, `notes` is an array of hashes containing specific note types (identified by their `label` property), and a `content` property containing the note text.

Specific instructions and definitions of archival note types may be found below. Not all possible note types may be documented. While `note` is the general XML property assigned to notes in MODS, not all ArchivesSpace notes are serialized as a MODS XML `note` field. See the MODS XML mappings below for details on where each note type is serialized.

**ArchivesSpace:** Archival Object: Notes

### Abstract

A concise summary of the key points of a larger work, often used to assist the reader in determining if that work is likely to be of use.

**MODS XML:** `abstract`  
**ArchivesSpace:** Archival Object: Note (with "abstract" type)

### Biographical/Historical

The biographical/historical note places the resource in context by providing basic information about its creator or author.

**MODS XML:** `note[@type = 'bioghist']`  
**ArchivesSpace:** Archival Object: Note (with "bioghist" type)

### Scope and Contents

A statement summarizing the range and topical coverage of the resource, often mentioning the form of the materials and naming significant organizations, individuals, events, places, and subjects represented.

**MODS XML:** `note[@type = 'scopecontent']`  
**ArchivesSpace:** Archival Object: Note (with "scopecontent" type)

### Language of Materials

The language(s), scripts, and symbol systems employed in the resource. Used when the Language provided is "Multiple languages" in order to convey which specific languages are present.

**MODS XML:** `note[@type = 'langmaterial']`  
**ArchivesSpace:** Archival Object: Note (with "langmaterial" type)

### Immediate Source of Acquisition

Information about how the resource came to be directly acquired by Special Collections and Archives. Historical provenance information preceding the immediate purchase or transfer is covered by the Custodial History note.

**MODS XML:** `note[@type = 'acqinfo']`  
**ArchivesSpace:** Archival Object: Note (with "acqinfo" type)

### Custodial History

Historical provenance information regarding the resource; how its ownership and custody changed over time, leading up to its transfer to Special Collections and Archives. Immediate purchase, gift, or donation information is covered by the Immediate Source of Acquisition note.

**MODS XML:** `note[@type = 'custodhist']`  
**ArchivesSpace:** Archival Object: Note (with "custodhist" type)

### Preferred Citation

Information regarding how users should identify the resource when referring to it in published credits.

**MODS XML:** `note[@type = 'prefercite']`  
**ArchivesSpace:** Archival Object: Note (with "prefercite" type)

### Related Materials

Information about materials that are not physically or logically included in the resource, but that may be of use to a reader because of an association to the resource.

**MODS XML:** `note[@type = 'relatedmaterial']`  
**ArchivesSpace:** Archival Object: Note (with "relatedmaterial" type)

### Conditions Governing Access

Conditions that affect the availability of the materials being described.

**MODS XML:** `accessCondition[@type = 'restrictionOnAccess']`  
**ArchivesSpace:** Archival Object: Note (with "accessrestrict" type)

### Conditions Governing Use

Conditions that affect the use of the described materials, such as in publications.

**MODS XML:** `accessCondition[@type = 'useAndReproduction']'`  
**ArchivesSpace:** Archival Object: Note (with "userestrict" type)

### Legal Status

The statutorily defined status of the materials being described.

**MODS XML:** `accessCondition[@type = 'legalStatus']`  
**ArchivesSpace:** Archival Object: Note (with "legalstatus" type)

### General

Any type of note not covered by the types described above.

**MODS XML:** `note[@type = 'odd']`  
**ArchivesSpace:** Archival Object: Note (with "odd" type)

## Parts

The files comprising the resource.

**MODS XML:** `part`  
**ArchivesSpace:** Digital Object Component

`parts` is constructed as an array of file objects (one per component attached to the Digital Object), consisting of the data properties listed below.

### Order

The order in which the file should be displayed in the compound object viewer. Is present even if the object is a simple object (containing one file). This is derived from the order in which the Digital Object Components are displayed in ArchivesSpace.

**MODS XML:** `part[@order]`  
**ArchivesSpace:** Digital Object Component (order of display)

### File Format

The file format of the Digital Object Component. Generated by the digital object creation Python script using libmagic.

**MODS XML:** `part[@type]`  
**ArchivesSpace:** Digital Object Component: File Version: File Format Name

### Title

The file name of the digital object component.

**MODS XML:** `part/detail/title`  
**ArchivesSpace:** Digital Object Component: File Version: File URI

### Caption

A brief description of the Digital Object Component, providing detail as to its content, such as the view depicted. Defaults to the file name (`part.title`) if none is provided.

**MODS XML:** `part/detail/caption`  
**ArchivesSpace:** Digital Object Component: File Version: Caption
