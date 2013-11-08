module Identity
  extend ActiveSupport::Concern

  included do
    before_create :ensure_uuid
    attr_readonly :uuid
  end

  def ensure_uuid
    write_attribute(:uuid, generate_uuid) unless self.uuid.present?
  end

  def to_param
    self.uuid || self.id
  end

  def serialize(options={})
    serializer = self.active_model_serializer || ActiveModel::DefaultSerializer

    serializer.new(self, options).serializable_hash
  end

  def generate_uuid
    loop do
      uuid = SecureRandom.urlsafe_base64(6).tr("+/=_-", "pqrsxyz")
      break uuid unless self.class.find_by_uuid(uuid)
    end
  end

  def eventable?
    self.class.eventable?
  end

  def actable?
    self.class.actable?
  end

  def identifiable?
    self.class.identifiable?
  end

  def publishable?
    self.class.publishable?
  end

  module ClassMethods
    # def cache_key
    # Digest::MD5.hexdigest "#{self.all.maximum(:updated_at).try(:to_i)}-#{self.count}"
    # end

    def find(*args)
      if !args[0].respond_to?(:match) || args[0].match(/^\d+$/) # assume we are an ID
        super(*args)
      else
        find_by(uuid: args[0])
      end
    end

    def identifiable?
      true
    end

    def actable?
      false
    end

    def eventable?
      false
    end

    def publishable?
      false
    end
  end

  def self.generate_uuid
    SecureRandom.urlsafe_base64(6).tr("+/=_-", "pqrsxyz")
  end
end
