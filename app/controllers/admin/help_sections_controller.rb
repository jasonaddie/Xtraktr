class Admin::HelpSectionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, @site_admin_role)
  end

  # GET /help_sections
  # GET /help_sections.json
  def index
    @root_help_sections = HelpSection.roots.sorted

    @css.push("help_section.css")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @help_sections }
    end
  end

  # GET /help_sections/1
  # GET /help_sections/1.json
  def show
    @help_section = HelpSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @help_section }
    end
  end

  # GET /help_sections/new
  # GET /help_sections/new.json
  def new
    @help_section = HelpSection.new

    @css.push("help_section.css")
    @js.push("help_section.js")

    set_tabbed_translation_form_settings('advanced')

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @help_section }
    end
  end

  # GET /help_sections/1/edit
  def edit
    @help_section = HelpSection.find(params[:id])
    @css.push("help_section.css")
    @js.push("help_section.js")
    set_tabbed_translation_form_settings('advanced')
  end

  # POST /help_sections
  # POST /help_sections.json
  def create
    @help_section = HelpSection.new(params[:help_section])

    respond_to do |format|
      if @help_section.save
        format.html { redirect_to admin_help_sections_path, notice: {success:  t('app.msgs.success_created', :obj => t('mongoid.models.help_section.one'))} }
        format.json { render json: @help_section, status: :created, location: @help_section }
      else
        @css.push("help_section.css")
        @js.push("help_section.js")
        set_tabbed_translation_form_settings('advanced')
        format.html { render action: "new" }
        format.json { render json: @help_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /help_sections/1
  # PUT /help_sections/1.json
  def update
    @help_section = HelpSection.find(params[:id])

    respond_to do |format|
      if @help_section.update_attributes(params[:help_section])
        format.html { redirect_to admin_help_sections_path, flash: {success:  t('app.msgs.success_updated', :obj => t('mongoid.models.help_section.one'))} }
        format.json { head :no_content }
      else
        @css.push("help_section.css")
        @js.push("help_section.js")
        set_tabbed_translation_form_settings('advanced')
        format.html { render action: "edit" }
        format.json { render json: @help_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /help_sections/1
  # DELETE /help_sections/1.json
  def destroy
    @help_section = HelpSection.find(params[:id])
    @help_section.destroy

    respond_to do |format|
      format.html { redirect_to admin_help_sections_url, flash: {success:  t('app.msgs.success_deleted', :obj => t('mongoid.models.help_section.one'))} }
      format.json { head :no_content }
    end
  end
end
