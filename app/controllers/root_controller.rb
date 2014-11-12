class RootController < ApplicationController

  layout "explore_data", only: [:explore_data_show, :private_share]

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def explore_data
    @datasets = Dataset.is_public.sorted

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def explore_data_show
    @dataset = Dataset.is_public.find_by(id: params[:id])

    if @dataset.blank?
      redirect_to explore_data_path, :notice => t('app.msgs.does_not_exist')
    else
      @is_admin = false
      @dataset_url = explore_data_show_path(@dataset)
      gon.explore_data = true
      gon.explore_data_ajax_path = explore_data_show_path(:format => :js)

      # this method is in application_controller
      # and gets all of the required information
      # and responds appropriately to html or js
      explore_data_generator(@dataset)
    end
  end
  
  def private_share
    @dataset = Dataset.by_private_key(params[:id])

    if @dataset.blank?
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    elsif @dataset.public?
      redirect_to explore_data_show_path(@dataset)      
    else
      @is_admin = false
      @dataset_url = private_share_path(@dataset.private_share_key)
      gon.explore_data = true
      gon.explore_data_ajax_path = private_share_path(:format => :js)

      # this method is in application_controller
      # and gets all of the required information
      # and responds appropriately to html or js
      explore_data_generator(@dataset)
    end
  end
  


end
