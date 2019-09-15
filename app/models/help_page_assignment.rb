class HelpPageAssignment
  include Mongoid::Document
  include Mongoid::Timestamps

  #############################

  belongs_to :help_page

  #############################

  field :controller, type: String
  field :action, type: String
  field :http_method, type: String

  #############################

  attr_accessible :controller, :action, :http_method

  #############################

  # indexes
  index ({ :help_page_id => 1})
  index ({ :controller => 1, :action => 1, :http_method => 1})

  #############################

  validates_presence_of :controller
  validates_presence_of :action
  validates_presence_of :http_method
  validates_inclusion_of :http_method, in: %w( GET POST PUT PATCH DELETE )

end
