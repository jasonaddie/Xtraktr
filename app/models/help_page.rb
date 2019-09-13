class HelpPage
  include Mongoid::Document
  include Mongoid::Timestamps

  #############################

  belongs_to :help_section

  #############################

  field :permalink, type: String
  field :title, type: String, localize: true
  field :summary, type: String, localize: true
  field :content, type: String, localize: true
  field :sort_order, type: Integer, default: 1
  field :public, type: Boolean, default: false
  field :public_at, type: Date

  #############################

  attr_accessible :permalink, :title, :title_translations, :summary, :summary_translations,
                  :content, :content_translations, :help_section_id,
                  :sort_order, :public, :public_at

  #############################

  # indexes
  index ({ :permalink => 1})
  index ({ :title => 1})
  index ({ :sort_order => 1})
  index ({ :help_section_id => 1})
  index ({ :public => 1})
  index ({ :public_at => 1})

  #############################
  # Validations
  validates_presence_of :permalink
  validates_uniqueness_of :permalink, scope: :help_section_id
  validate :validate_translations

  # validate the translation fields
  # title need to be validated for presence
  def validate_translations
    logger.debug "***** validates translations"
    default_language = I18n.default_locale.to_s
    if default_language.present?
      logger.debug "***** - default is present; title = #{self.title_translations[default_language]}"
      if self.title_translations[default_language].blank?
        errors.add(:base, I18n.t('errors.messages.translation_default_lang',
            field_name: self.class.human_attribute_name('title'),
            language: Language.get_name(default_language),
            msg: I18n.t('errors.messages.blank')) )
      end
    end
  end

  #############################
  # Callbacks
  before_save :set_to_nil
  before_save :set_public_at

  # if title are '', reset value to nil so fallback works
  def set_to_nil
    self.title_translations.keys.each do |key|
      self.title_translations[key] = nil if !self.title_translations[key].nil? && self.title_translations[key].empty?
    end
  end

  # if public and public at not exist, set it
  # else, make nil
  def set_public_at
    if self.public? && self.public_at.nil?
      self.public_at = Time.now.to_date
    elsif !self.public?
      self.public_at = nil
    end
  end

  #############################

  def self.is_public
    where(public: true)
  end

  def self.sorted
    order_by([[:sort_order, :asc], [:title, :asc]])
  end

  def self.by_permalink(permalink)
    find_by(permalink: permalink)
  end

  def self.in_help_section(help_section_id)
    where(help_section_id: help_section_id)
  end

end
