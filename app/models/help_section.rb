class HelpSection
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry


  #############################

  has_ancestry

  #############################

  has_many :help_pages, dependent: :destroy

  #############################

  field :permalink, type: String
  field :permalink_with_ancestors, type: String
  field :title, type: String, localize: true
  field :summary, type: String, localize: true
  field :sort_order, type: Integer, default: 1
  # whether or not can be shown to public
  field :public, type: Boolean, default: false
  # when made public
  field :public_at, type: Date

  #############################
  accepts_nested_attributes_for :help_pages, :reject_if => :all_blank, :allow_destroy => true

  attr_accessible :permalink, :title, :title_translations, :summary, :summary_translations,
                  :sort_order, :public, :public_at, :parent_id,
                  :help_pages_attributes

  attr_accessor :update_descendant_permalink_with_ancestors, :descendants_to_update

  #############################

  # indexes
  index ({ :permalink => 1})
  index ({ :permalink_with_ancestors => 1})
  index ({ :title => 1})
  index ({ :sort_order => 1})
  index ({ :public => 1})
  index ({ :public_at => 1})

  #############################
  # Validations
  validates_presence_of :permalink
  validates_uniqueness_of :permalink, scope: :ancestry
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
  before_save :check_if_permalink_changing
  after_save :update_descendant_permalink_references
  before_validation :check_if_parent_changing

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

  # if the parent is changing, save the descendants
  # so after the save is complete their permalink_with_ancestor
  # value can be updated
  # - due to parent changing, all descendant ancestry values are updated
  #   before this item is saved and so all references to the descendants are lost
  def check_if_parent_changing
    # puts "================ check_if_parent_changing for #{self.title}"
    if self.ancestry_changed?
      # puts ">>> changed!"
      update_permalink_with_ancestors

      if !self.new_record?
        self.descendants_to_update = self.descendants.to_a
        self.update_descendant_permalink_with_ancestors = true
      end
    end
  end

  # if the permalink is changing, update permalink_with_ancestors
  def check_if_permalink_changing
    # puts "================ check_if_permalink_changing for #{self.title}"
    if self.permalink_changed?
      # puts ">>> changed!"
      update_permalink_with_ancestors

      # indicate that the descendant permalinks should be updated after save
      self.update_descendant_permalink_with_ancestors = true
    end
  end

  # if the permalink changed, update the descendants of this section
  # so that their permalink_with_ancestors is correct
  def update_descendant_permalink_references
    # puts "================ update_descendant_permalink_references for #{self.title}"
    # puts ">> update_descendant_permalink_with_ancestors = #{self.update_descendant_permalink_with_ancestors}; descendant = #{self.descendants.present?}; descendants_to_update = #{self.descendants_to_update.present?}"
    if self.update_descendant_permalink_with_ancestors && (self.descendants.present? || self.descendants_to_update.present?)
      descendants = self.descendants_to_update.present? ? self.descendants_to_update : self.descendants
      # puts ">>>>>> need to update descendant permalinks; there are #{descendants.length} descendants records"
      descendants.each do |descendant|
        descendant.update_permalink_with_ancestors
        descendant.save
      end
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
    find_by(permalink_with_ancestors: permalink)
  end

  # update the complete permalink with the parent and self permalinks
  def update_permalink_with_ancestors
    # puts "================ update_permalink_with_ancestors for #{self.title}"
    permalinks = get_ancestry_permalinks(self)
    permalinks.flatten!
    self.permalink_with_ancestors = permalinks.present? ? permalinks.reverse.join('/') : nil
  end

  def get_ancestry_permalinks(help_section)
    permalinks = []

    if help_section.present?
      permalinks << help_section.permalink
      if help_section.parent_id.present?
        permalinks << get_ancestry_permalinks(help_section.parent)
      end
    end

    return permalinks
  end
end