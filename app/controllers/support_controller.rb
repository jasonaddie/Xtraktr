class SupportController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, @site_admin_role)
  end
  before_filter :get_section, except: [:index]

  def index
    # get all root section
    @root_sections = HelpSection.roots.sorted.is_public

    @css.push('support.css')

    respond_to do |format|
      format.html
    end
  end

  def section
    # help_section is set in the get_section private method

    @css.push('support.css')

    respond_to do |format|
      format.html
    end
  end

  def page
    @help_page = HelpPage.is_public.in_help_section(@help_section.id).by_permalink(params[:page_id])

    @css.push('support.css')

    if @help_page.present?
      respond_to do |format|
        format.html
      end
    else
      flash[:info] =  t('app.msgs.does_not_exist')
      redirect_to support_path(:locale => I18n.locale)
      return
    end
  end

  private

  def get_section
    @help_section = HelpSection.is_public.by_permalink(params[:section_id])

    if @help_section.nil?
      flash[:info] =  t('app.msgs.does_not_exist')
      redirect_to support_path(:locale => I18n.locale)
      return
    end
  end

end
