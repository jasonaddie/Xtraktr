module HelpSectionsHelper


  # build a list of select options
  # that have the help sections in order and with heirarchy
  # - each heirarchy is indicated by css class
  def build_help_section_ordered_select_options(current_item, default_value)
    return build_options_for_help_section_level(HelpSection.roots.sorted, current_item, default_value, 1)
  end

  # build an array of help sections that is ordered in the proper heirarchy
  def build_help_section_heirarchy_list(help_sections)
    items = order_list_for_help_section_level(help_sections)
    return items.flatten
  end

  private

  def build_options_for_help_section_level(help_sections, current_item, default_value, level=1)
    html = ''
    if help_sections.present?
      help_sections.each do |help_section|
        selected = help_section.id == default_value ? 'selected=selected' : ''
        disabled = help_section.id == current_item ? 'disabled=disabled' : ''
        html += "<option value='#{help_section.id}' #{selected} #{disabled} class='l#{level}'>#{help_section.title}</option>"
        html += build_options_for_help_section_level(help_section.children.sorted, current_item, default_value, level+1)
      end
    end

    return html
  end

  def order_list_for_help_section_level(help_sections)
    items = []
    if help_sections.present?
      help_sections.each do |help_section|
        items << help_section
        items << order_list_for_help_section_level(help_section.children.sorted)
      end
    end

    return items
  end

end
