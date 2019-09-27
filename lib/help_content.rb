# encoding: utf-8

module HelpContent

  #######################
  ## global variables
  @@json_file_template = "#{Rails.root}/data_files/help_section_and_pages_template.json"
  @@json_file_export = "#{Rails.root}/data_files/help_section_and_pages_export.json"

  # load the help sections and pages from the
  # json data file at data_files/help_section_and_pages.json
  def self.import(delete_all_records=false, from_template=true)
    puts "HelpContent.import - start"
    start = Time.now

    json_file = from_template == true ? @@json_file_template : @@json_file_export

    if File.exists?(json_file)
      puts "> json file exists"
      json = JSON.parse(File.read(json_file))

      if json.present?
        puts "> have json data"

        # delete all records
        if delete_all_records
          HelpPage.destroy_all
          HelpSection.destroy_all
        end

        # process pages
        import_process_pages(json['pages'], nil)

        # process sections and any sub-sections / pages in that section
        import_process_sections(json['sections'], nil)

      else
        puts "******************************"
        puts "ERROR"
        puts "The json file at #{@@json_file_template} does not have any content!"
        puts "******************************"
      end
    else
      puts "******************************"
      puts "ERROR"
      puts "The json file at #{@@json_file_template} does not exist!"
      puts "******************************"
    end
    puts "******************************"
    puts "FINISHED!"
    puts "It took #{Time.now - start} seconds to create #{HelpSection.all.count} help sections and #{HelpPage.all.count} help pages."
    puts "******************************"

  end

  # export all of the help sections and pages
  # to a json file
  def self.export
    puts "HelpContent.export - start"
    start = Time.now
    json = {}

    sections = HelpSection.roots.sorted
    if sections.present?
      # for each root section, create the json node
      # and then process any child sections and pages
      json['sections'] = export_process_sections(sections)

      # write json to file
      File.open(@@json_file_export,"w") do |f|
        f.write(JSON.pretty_generate(json))
      end
    else
      puts "******************************"
      puts "ERROR"
      puts "There are no sections on file!"
      puts "******************************"
    end

    puts "******************************"
    puts "FINISHED!"
    puts "It took #{Time.now - start} seconds to export the help sections and help pages."
    puts "******************************"

  end

  private

  def self.import_process_pages(pages, parent_section)
    if pages.present?
      pages.each_with_index do |page, i|
        create_page(page, parent_section, i+1)
      end
    end
  end

  # create a new help page record
  def self.create_page(hash, parent_section, sort_order)
    puts ">>> PAGE #{hash['title']}"
    page = HelpPage.new
    page.title = hash['title']
    page.summary = hash['summary']
    page.content = hash['content'] if hash['content'].present?
    page.permalink = hash['permalink']
    page.help_section_id = parent_section.id
    page.sort_order = sort_order
    page.show_in_subnavbar = hash['show_in_subnavbar'] if hash['show_in_subnavbar'].present?

    page.public = true

    if hash['assignments'].present?
      puts ">>>>> adding #{hash['assignments'].length} assignments"
      hash['assignments'].each do |assignment|
        page.help_page_assignments.build(
          controller: assignment['controller'],
          action: assignment['action'],
          http_method: assignment['http_method']
        )
      end
    end

    page.save
  end

  def self.import_process_sections(sections, parent_section)
    if sections.present?
      sections.each_with_index do |section, i|
        new_section = create_section(section, parent_section, i+1)

        # if have pages, process them
        import_process_pages(section['pages'], new_section)

        # if have sub-sections, process them
        import_process_sections(section['sections'], new_section)
      end
    end
  end

  # create a new help section record
  def self.create_section(hash, parent_section, sort_order)
    puts ">>> SECTION #{hash['title']}"
    puts ">>> #{parent_section.inspect}"
    section = HelpSection.new
    section.title = hash['title']
    section.summary = hash['summary']
    section.permalink = hash['permalink']
    section.parent_id = parent_section.id if parent_section.present?
    section.sort_order = sort_order
    section.public = true
    section.for_admin_only = hash['for_admin_only'] if hash['for_admin_only'].present?
    section.save

    return section
  end


  def self.export_process_pages(pages)
    puts ">> export_process_pages - start"
    pages_json = []
    if pages.present?
      pages.each do |page|
        pages_json << create_page_json(page)
      end
    end
    return pages_json
  end

  def self.create_page_json(page)
    json = {
      "title": page.title,
      "summary": page.summary,
      "permalink": page.permalink
    }

    if !page.content.nil? && page.content.strip.present?
      json['content'] = page.content
    end

    if page.show_in_subnavbar == true
      json['show_in_subnavbar'] = true
    end

    if page.help_page_assignments.present?
      json['assignments'] = []
      page.help_page_assignments.each do |assignment|
        json['assignments'] << {
          "controller": assignment.controller,
          "action": assignment.action,
          "http_method": assignment.http_method
        }
      end
    end

    return json
  end

  def self.export_process_sections(sections)
    puts ">> export_process_sections - start"
    sections_json = []
    if sections.present?
      sections.each do |section|
        section_json = create_section_json(section)
        sections_json << section_json

        # if have sub-sections, process them
        sub_sections = export_process_sections(section.children.sorted)
        if sub_sections.present?
          section_json['sections'] = sub_sections
        end

        # if have pages, process them
        sub_pages = export_process_pages(section.help_pages.sorted)
        if sub_pages.present?
          section_json['pages'] = sub_pages
        end

      end
    end

    puts sections
    return sections_json
  end

  def self.create_section_json(section)
    json = {
      "title": section.title,
      "summary": section.summary,
      "permalink": section.permalink
    }

    if section.for_admin_only == true
      json['for_admin_only'] = true
    end

    return json
  end



end