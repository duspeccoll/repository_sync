class RepositorySerializer < ASpaceExport::Serializer
  serializer_for :repository

  include JSONModel

  def serialize(mods, opts = {})
    record = {
      'title' => mods.title,
      'uri' => mods.uri,
      'identifiers' => [{'type': "local", 'identifier': mods.local_identifier}]
    }

    unless mods.language_term.nil?
      language = mods.language_term.split(":")
      record['language'] = {
        'text' => language[0],
        'code' => language[1],
        'authority' => "iso639-2b"
      }
    end

    unless mods.dates.empty?
      record['dates'] = []
      mods.dates.each {|date| record['dates'].push(handle_date(date))}
    end

    unless mods.extents.empty?
      record['extents'] = []
      mods.extents.each {|extent| record['extents'].push(extent)}
    end

    record['subjects'] = []
    mods.subjects.each do |subject|
      subj = {
        'authority': subject['source'],
        'title': subject['title']
      }

      terms = []
      unless subject['terms'].nil? or subject['terms'].empty?
        subject['terms'].each {|term| terms.push({'type': term['type'], 'term': term['term']})}
        subj['terms'] = terms
      end

      subj['authority_id'] = subject['authority_id'] if subject['authority_id']

      record['subjects'].push(subj)
    end

    record['notes'] = []
    unless mods.notes.empty?
      mods.notes.each do |note|
        record['notes'].push({
          'type' => note['type'],
          'content' => note['content']
        })
      end
    end

    record['names'] = []
    unless mods.names.empty?
      mods.names.each do |name|
        record['names'].push name
      end
    end

    record['parts'] = []
    mods.parts.each {|part| record['parts'].push part} unless mods.parts.empty?

    record
  end

  private

  def handle_date(date)
    date_object = { 'encoding' => "w3cdtf" }

    if date.has_key?('certainty')
      date_object['qualifier'] = date['certainty']
    end

    # has an human-readable expression been provided?
    has_expression = date.has_key?('expression') &&
                  !date['expression'].nil? &&
                  !date['expression'].empty?

    # was a begin date provided?
    has_begin = date.has_key?('begin') &&
                !date['begin'].nil? &&
                !date['begin'].empty?

    # is the date a range? was an end date provided?
    has_end = date.has_key?('end') &&
              !date['end'].nil? &&
              !date['end'].empty?

    # the tag created depends on the type of date
    case date['label']
    when 'creation', 'digitized', 'copyright', 'modified', 'issued'
      date_object['type'] = date['label']
    when 'broadcast', 'publication'
      date_object['type'] = "issued"
    else
      date_object['type'] = "other"
    end

    # assign the human-readable expression (to display to users)
    if has_expression
      date_object['expression'] = date['expression']
    else
      date_object['expression'] = "#{date['begin']}"
      date_object['expression'] += "-#{date['end']}" if has_end
    end

    # assign the begin and end dates (to be used by elastic for indexing)
    date_object['begin'] = date['begin'] if has_begin
    date_object['end'] = date['end'] if has_end

    date_object
  end
end
