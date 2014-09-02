module Blokade::Concerns::RoleConcerns
  extend ActiveSupport::Concern

  included do
    belongs_to Blokade.blockadable_class.model_name.singular.to_sym, class_name: Blokade.blockadable_class.to_s

    has_many :grants, dependent: :destroy, class_name: Blokade.grant_class.to_s
    has_many :permissions, through: :grants
    has_many :powers, dependent: :destroy, class_name: Blokade.power_class.to_s
    has_many :users, through: :powers, class_name: Blokade.user_class.to_s

    before_validation :generate_key


    def to_param
      "#{id}-#{name}".parameterize
    end

    private

    def generate_key
      self.key = name.parameterize unless key.present?
    end
  end

  module ClassMethods
    def get(key)
      where(key: key).first
    end
  end

end