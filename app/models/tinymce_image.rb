class TinymceImage
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  #############################
  has_mongoid_attached_file :file,
    url: "/system/text_images/:id/:style/:filename",
    use_timestamp: false,
    styles: {
      large: {:geometry => "1000x1000>"}
    },
    convert_options: {
      large: '-quality 85'
    }

  field :alt, type: String
  field :hint, type: String

  #############################
  attr_accessible :file, :alt, :hint

  #############################
  # Validations
  validates_attachment_content_type :file, content_type: /\Aimage/
  validates_attachment_file_name :file, matches: [/png\z/, /gif\z/, /jpe?g\z/]


end
