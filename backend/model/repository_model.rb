class RepositoryModel < ASpaceExport::ExportModel
  model_for :repository

  include JSONModel

  attr_accessor :title
  attr_accessor :uri
  attr_accessor :local_identifier
  attr_accessor :language_term
  attr_accessor :extents
  attr_accessor :extent_notes
  attr_accessor :notes
  attr_accessor :subjects
  attr_accessor :names
  attr_accessor :dates
  attr_accessor :parts

  @archival_object_map = {
    [:title, :dates] => :handle_title,
    :uri => :uri=,
    :component_id => :local_identifier=,
    :language => :handle_language,
    :dates => :handle_dates,
    [:extents, :notes] => :handle_extents,
    :subjects => :handle_subjects,
    :linked_agents => :handle_agents,
    :notes => :handle_notes,
    :instances => :handle_instances
  }

  @name_type_map = {
    'agent_person' => 'personal',
    'agent_family' => 'family',
    'agent_corporate_entity' => 'corporate',
    'agent_software' => nil
  }

  @name_part_type_map = {
    'primary_name' => 'family',
    'title' => 'termsOfAddress',
    'rest_of_name' => 'given',
    'family_name' => 'family',
    'prefix' => 'termsOfAddress'
  }

  @mime_type_map = {
    'aiff' => "audio/x-aiff",
    'avi' => "video/x-msvideo",
    'gif' => "image/gif",
    'jpeg' => "image/jpeg",
    'mov' => "video/quicktime",
    'mp3' => "audio/mp3",
    'pdf' => "application/pdf",
    'tiff' => "image/tiff",
    'txt' => "text/plain",
    'wav' => "audio/x-wav"
  }

  def initialize
    @extents = []
    @notes = []
    @extent_notes = []
    @subjects = []
    @names = []
    @parts = []
    @name_parts = []
    @dates = []
  end

  # meaning, 'archival object' in the abstract
  def self.from_archival_object(obj)

    mods = self.new
    mods.apply_map(obj, @archival_object_map)

    mods
  end

  def self.name_type_map
    @name_type_map
  end

  def self.name_part_type_map
    @name_part_type_map
  end

  def self.mime_type_map
    @mime_type_map
  end

  def handle_title(title, dates)
    t = title
    dates.each do |date|
      if date['label'] == "creation"
        t << ", #{date['expression']}"
      end
    end

    self.title = t
  end


  def handle_notes(notes)
    notes.each do |note|
      # physdesc and dimensions are treated separately from other notes
      next if note['type'] == 'physdesc' || note['type'] == 'dimensions'
      next unless note['publish'] == true

      content = ASpaceExport::Utils.extract_note_text(note)
      self.notes << {'type' => note['type'], 'content' => content}
    end
  end

  # notes relating to extents are treated differently than other notes
  # when the model is serialized.
  def handle_extents_notes(notes)
    notes.each do |note|
      next unless note['type'] == 'physdesc' || note['type'] == 'dimensions'
      next unless note['publish'] == true

      content = ASpaceExport::Utils.extract_note_text(note)
      self.extent_notes << {'type' => note['type'], 'content' => content}
    end
  end


  def handle_extents(extents, notes)
    extents.each do |ext|
      e = ext['number']
      e << " #{ext['extent_type']}"
      e << " (#{ext['portion']})" if ext['portion']

      self.extents << e

      # the extents hash may have data under keys 'physical_details' and 'dimensions'.
      # If found, we'll treat them as if they were notes of that type.
      if ext.has_key?('physical_details') && !ext['physical_details'].nil?
        extent_notes << {'type' => "phystech", 'content' => ext['physical_details']}
      end

      if ext.has_key?('dimensions') && !ext['dimensions'].nil?
        extent_notes << {'type' => "dimensions", 'content' => ext['dimensions']}
      end
    end

    # process any physical_details and dimension notes that may be in the note list.
    handle_extents_notes(notes)
  end


  def handle_subjects(subjects)
    subjects.map {|s| s['_resolved'] }.each do |subject|
      terms = []
      subject['terms'].each do |t|
        term = {'term' => t['term'], 'type' => t['term_type']}
        terms.push term
      end

      self.subjects << {
        'source' => subject['source'],
        'terms' => terms,
        'title' => terms.map{|t| t['term']}.join(' -- '),
        'authority_id' => subject['authority_id']
      }
    end
  end


  # add <parts> to the physicalDescription wrapper if a representative digital object
  # is linked to the item record
  def handle_instances(instances)
    instances.each do |instance|
      if instance['instance_type'] == "digital_object" && instance['is_representative'] == true
        object = instance['digital_object']['_resolved']
        object['file_versions'].each_with_index do |part, i|
          self.parts << {
            'type' => self.class.mime_type_map[part['file_format_name']],
            'order' => (i+1).to_s,
            'title' => part['file_uri'],
            'caption' => part['caption']
          }
        end
      end
    end
  end


  def handle_agents(linked_agents)
    linked_agents.each do |link|
      agent = link['_resolved']
      name = {
        'title' => agent['title'],
        'source' => agent['display_name']['source'],
        'type' => link['jsonmodel_type']
      }
      name['authority_id'] = agent['display_name']['authority_id'] if agent['display_name']['authority_id']
      if link['role'] == "subject"
        self.subjects << name
      else
        self.names << name
      end
    end
  end


  def handle_dates(dates)
    dates.each do |date|
      self.dates.push date
    end
  end


  def handle_language(language_term)
    unless language_term.nil? || language_term.empty?
      self.language_term = I18n.t("enumerations.language_iso639_2." + language_term) + ":" + language_term
    else
      self.language_term = nil
    end
  end


  def get_name_parts(name, type)
    fields = case type
             when 'agent_person'
               ["primary_name", "title", "prefix", "rest_of_name", "suffix", "fuller_form", "number"]
             when 'agent_family'
               ["family_name", "prefix"]
             when 'agent_software'
               ["software_name", "version", "manufacturer"]
             when 'agent_corporate_entity'
               ["primary_name", "subordinate_name_1", "subordinate_name_2", "number"]
             end
    name_parts = []
    fields.each do |field|
      name_part = {}
      name_part['type'] = self.class.name_part_type_map[field]
      name_part.delete('type') if name_part['type'].nil?
      name_part['content'] = name[field] unless name[field].nil?
      name_parts << name_part unless name_part.empty?
    end
    name_parts
  end

end
