module HelpSectionsHelper


  # build a list of select options
  # that have the help sections in order and with heirarchy
  # - each heirarchy is indicated by css class
  def build_help_section_ordered_select_options(default_value, current_item=nil)
    return build_options_for_help_section_level(HelpSection.roots.sorted, default_value, current_item, 1)
  end

  # build an array of help sections that is ordered in the proper heirarchy
  def build_help_section_heirarchy_list(help_sections)
    items = order_list_for_help_section_level(help_sections)
    return items.flatten
  end

  # build a breadcrumb like heirarchy of the help sections
  # that ends with the provided `end_help_section`
  def build_help_section_breadcrumb_text(end_help_section)
    titles = build_breadcrumb_item_for_help_section(end_help_section)
    titles.flatten!

    return titles.present? ? titles.reverse.join(' > ') : ''
  end

  # build a breadcrumb like heirarchy of the help sections
  # that ends with the provided `end_help_section`
  # each breadcrumb is a link to that section
  def build_help_section_breadcrumb_links(end_help_section)
    links = build_breadcrumb_link_for_help_section(end_help_section)
    links.flatten!
    return links.present? ? links.reverse.join(' > ') : ''
  end

  private

  def build_breadcrumb_item_for_help_section(help_section)
    titles = []

    if help_section.present?
      titles << help_section.title
      if help_section.parent_id.present?
        titles << build_breadcrumb_item_for_help_section(help_section.parent)
      end
    end

    return titles
  end

  def build_breadcrumb_link_for_help_section(help_section)
    links = []

    if help_section.present?
      links << link_to(help_section.title, support_guide_book_path(help_section.permalink_with_ancestors))

      if help_section.parent_id.present?
        links << build_breadcrumb_link_for_help_section(help_section.parent)
      end
    end

    return links
  end

  def build_options_for_help_section_level(help_sections, default_value, current_item, level=1)
    html = ''
    if help_sections.present?
      help_sections.each do |help_section|
        selected = help_section.id == default_value ? 'selected=selected' : ''
        disabled = help_section.id == current_item ? 'disabled=disabled' : ''
        html += "<option value='#{help_section.id}' #{selected} #{disabled} class='l#{level}'>#{help_section.title}</option>"
        html += build_options_for_help_section_level(help_section.children.sorted, default_value, current_item, level+1)
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
