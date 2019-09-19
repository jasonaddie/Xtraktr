# encoding: utf-8

# load the help sections and pages from the
# json data file at data_files/help_section_and_pages.json

module LoadHelpContent

  #######################
  ## global variables
  @@json_file = "#{Rails.root}/data_files/help_section_and_pages.json"

  def self.run(delete_all_records=false)
    puts "LoadHelpContent.run - start"
    start = Time.now

    if File.exists?(@@json_file)
      puts "> json file exists"
      json = JSON.parse(File.read(@@json_file))

      if json.present?
        puts "> have json data"

        # delete all records
        if delete_all_records
          HelpPage.destroy_all
          HelpSection.destroy_all
        end

        # process pages
        process_pages(json['pages'], nil)

        # process sections and any sub-sections / pages in that section
        process_sections(json['sections'], nil)

      else
        puts "******************************"
        puts "ERROR"
        puts "The json file at #{@@json_file} does not have any content!"
        puts "******************************"
      end
    else
      puts "******************************"
      puts "ERROR"
      puts "The json file at #{@@json_file} does not exist!"
      puts "******************************"
    end
    puts "******************************"
    puts "FINISHED!"
    puts "It took #{Time.now - start} seconds to create #{HelpSection.all.count} help sections and #{HelpPage.all.count} help pages."
    puts "******************************"

  end

  private

  def self.process_pages(pages, parent_section)
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

  def self.process_sections(sections, parent_section)
    if sections.present?
      sections.each_with_index do |section, i|
        new_section = create_section(section, parent_section, i+1)

        # if have pages, process them
        process_pages(section['pages'], new_section)

        # if have sub-sections, process them
        process_sections(section['sections'], new_section)
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
    section.save

    return section
  end
end