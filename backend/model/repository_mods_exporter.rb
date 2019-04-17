class RepositoryMODSSerializer < ASpaceExport::Serializer
  serializer_for :repository_mods

  include JSONModel

  def serialize(mods, opts = {})

    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      serialize_mods(mods, xml)
    end

    builder.to_xml
  end

  def serialize_mods(mods, xml)

    root_args = {'version' => '3.4'}
    root_args['xmlns'] = 'http://www.loc.gov/mods/v3'

    xml.mods(root_args){
      serialize_mods_inner(mods, xml)
    }
  end


  def serialize_mods_inner(mods, xml)

    xml.titleInfo {
      xml.title mods.title
    }

    xml.identifier(:type => 'local') {
      xml.text mods.local_identifier
    }

    unless mods.language_term.nil?
      xml.language {
        xml.languageTerm(:type => 'text', :authority => 'iso639-2b') {
          xml.text mods.language_term.split(":")[0]
        }

        xml.languageTerm(:type => 'code', :authority => 'iso639-2b') {
          xml.text mods.language_term.split(":")[1]
        }
      }
    end

    unless mods.dates.empty?
      xml.originInfo {
        mods.dates.each do |date|
          handle_date(xml, date)
        end
      }
    end

    xml.physicalDescription {
      unless mods.extents.empty?
        mods.extents.each do |extent|
          xml.extent extent
        end
      end

      unless mods.extent_notes.empty?
        mods.extent_notes.each do |note|
          serialize_note(note, xml)
        end
      end

      unless mods.digital_origin.empty?
        xml.digitalOrigin {
          xml.text mods.digital_origin
        }
      end
    }

    mods.notes.each do |note|
      if note.wrapping_tag
        xml.send(note.wrapping_tag) {
          serialize_note(note, xml)
        }
      else
        serialize_note(note, xml)
      end
    end

    if (repo_note = mods.repository_note)
      xml.note(:displayLabel => repo_note.label) {
        xml.text repo_note.content
      }
    end

    mods.subjects.each do |subject|
      xml.subject(:authority => subject['source'], :authorityURI => subject['authority_id']) {
        subject['terms'].each do |term|
          case term['type']
          when 'geographic'
            xml.geographic term['term']
          when 'temporal'
            xml.temporal term['term']
          when 'uniformTitle'
            xml.titleInfo {
              xml.title term['term']
            }
          when 'genre_form'
            xml.genre term['term']
          when 'occupation'
            xml.occupation term['term']
          else
            xml.topic term['term']
          end
        end
      }
    end

    mods.names.each do |name|
      case name['role']
      when 'subject'
        xml.subject {
          serialize_name(name, xml)
        }
      else
        serialize_name(name, xml)
      end
    end

    mods.parts.each do |part|
      xml.part(:type => part['type'], :order => part['order']) {
        xml.detail {
          xml.title part['name']
          xml.caption part['caption']
        }
      }
    end

  end


  # wrapped the namePart in an 'unless' so it wouldn't export empty tags
  def serialize_name(name, xml)
    atts = {:type => name['type']}
    atts[:authority] = name['source'] if name['source']
    xml.name(atts) {
      name['parts'].each do |part|
        unless part['content'].nil?
          if part['type']
            xml.namePart(:type => part['type']) {
              xml.text part['content']
            }
          else
            xml.namePart part['content']
          end
        end
      end
      unless name['role'] == 'subject'
        xml.role {
          xml.roleTerm(:type => 'text', :authority => 'marcrelator') {
            xml.text name['role']
          }
        }
      end
    }
  end


  def serialize_note(note, xml)
    atts = {}
    atts[:type] = note.type if note.type
    atts[:displayLabel] = note.label if note.label

    xml.send(note.tag, atts) {
      xml.text note.content
    }
  end

  private

  def handle_date(xml, date)
    attrs = process_date_qualifier_attrs(date)

    # if expression is provided, use that for this date
    has_expression = date.has_key?('expression') &&
                  !date['expression'].nil? &&
                  !date['expression'].empty?

    # if end specified, we need a point="end" tag.
    has_end = date.has_key?('end') &&
              !date['end'].nil? &&
              !date['end'].empty? &&
              !has_expression

    # if beginning specified, we need a point="start" tag.
    has_begin = date.has_key?('begin') &&
                !date['begin'].nil? &&
                !date['begin'].empty? &&
                !has_expression

    # the tag created depends on the type of date
    case date['label']
    when 'creation'
      type = "dateCreated"
    when 'digitized'
      type = "dateCaptured"
    when 'copyright'
      type = "copyrightDate"
    when 'modified'
      type = "dateModified"
    when 'broadcast', 'issued', 'publication'
      type = "dateIssued"
    else
      type = "dateOther"
    end

    if has_expression
      xml.send(type, attrs) { xml.text(date['expression']) }
    else
      if has_begin
        attrs.merge!({"encoding" => "w3cdtf", "keyDate" => "yes", "point" => "start"})
        xml.send(type, attrs) { xml.text(date['begin']) }
      end

      if has_end
        attrs.merge!({"encoding" => "w3cdtf", "keyDate" => "yes", "point" => "end"})
        xml.send(type, attrs) { xml.text(date['end']) }
      end
    end
  end


  def process_date_qualifier_attrs(date)
    attrs = {}

    if date.has_key?('certainty')
      case date['certainty']
      when "approximate"
        attrs["qualifier"] = "approximate"
      when "inferred"
        attrs["qualifier"] = "inferred"
      when "questionable"
        attrs["qualifier"] = "questionable"
      end
    end

    return attrs
  end
end
