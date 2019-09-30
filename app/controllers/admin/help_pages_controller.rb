class Admin::HelpPagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, @site_admin_role)
  end

  # GET /help_pages
  # GET /help_pages.json
  def index
    @help_pages = HelpPage.all

    @js.push('search.js')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @help_pages }
    end
  end

  # GET /help_pages/1
  # GET /help_pages/1.json
  def show
    @help_page = HelpPage.find(params[:id])

    @css.push('support_tinymce.css')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @help_page }
    end
  end

  # GET /help_pages/new
  # GET /help_pages/new.json
  def new
    @help_page = HelpPage.new

    @css.push("help_section.css")
    @js.push("help_section.js", 'cocoon.js')

    set_tabbed_translation_form_settings

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @help_page }
    end
  end

  # GET /help_pages/1/edit
  def edit
    @help_page = HelpPage.find(params[:id])
    set_tabbed_translation_form_settings
    @css.push("help_section.css")
    @js.push("help_section.js", 'cocoon.js')
  end

  # POST /help_pages
  # POST /help_pages.json
  def create
    @help_page = HelpPage.new(params[:help_page])

    respond_to do |format|
      if @help_page.save
        format.html { redirect_to [:admin,@help_page], notice: {success:  t('app.msgs.success_created', :obj => t('mongoid.models.help_page.one'))} }
        format.json { render json: @help_page, status: :created, location: @help_page }
      else
        @css.push("help_section.css")
        @js.push("help_section.js", 'cocoon.js')
        set_tabbed_translation_form_settings
        format.html { render action: "new" }
        format.json { render json: @help_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /help_pages/1
  # PUT /help_pages/1.json
  def update
    @help_page = HelpPage.find(params[:id])

    respond_to do |format|
      if @help_page.update_attributes(params[:help_page])
        format.html { redirect_to [:admin,@help_page], flash: {success:  t('app.msgs.success_updated', :obj => t('mongoid.models.help_page.one'))} }
        format.json { head :no_content }
      else
        @css.push("help_section.css")
        @js.push("help_section.js", 'cocoon.js')
        set_tabbed_translation_form_settings
        format.html { render action: "edit" }
        format.json { render json: @help_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /help_pages/1
  # DELETE /help_pages/1.json
  def destroy
    @help_page = HelpPage.find(params[:id])
    @help_page.destroy

    respond_to do |format|
      format.html { redirect_to admin_help_pages_url, flash: {success:  t('app.msgs.success_deleted', :obj => t('mongoid.models.help_section.one'))} }
      format.json { head :no_content }
    end
  end
end
