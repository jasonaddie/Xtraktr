class SupportController < ApplicationController
  before_filter :get_section, except: [:index]

  def index
    # get all root section
    @root_sections = HelpSection.roots.sorted.is_public.restrict_by_user_role(public_only?)

    @css.push('support.css')

    respond_to do |format|
      format.html
    end
  end

  def guide_book
    # help_section is set in the get_section private method

    @css.push('support.css')

    respond_to do |format|
      format.html
    end
  end

  def guide
    @help_page = HelpPage.is_public.in_help_section(@help_section.id).by_permalink(params[:guide_id])

    @css.push('support.css')
    @js.push('anchor.min.js', 'support.js')

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

  def public_only?
    !(user_signed_in? && current_user.role?(@site_admin_role))
  end

  def get_section
    @help_section = HelpSection.is_public.restrict_by_user_role(public_only?).by_permalink(params[:guide_book_id])

    if @help_section.nil?
      flash[:info] =  t('app.msgs.does_not_exist')
      redirect_to support_path(:locale => I18n.locale)
      return
    end
  end

end
