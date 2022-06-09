# frozen_string_literal: true

module ActiveStorage
  module DirectUploadsHelper
    # Requires a `Model.attribute` formatted string that represents the
    # validations to be run. For example, if passed "User.avatar" ActiveStorage
    # will run the ActiveStorage related validations defined for the User
    # model's avatar attribute.
    #
    # Returns a signed string
    def rails_direct_uploads_signed_model_and_attribute(model_and_attribute)
      klass_name, attribute = model_and_attribute.split(".")
      model = ActiveRecord::Base.const_get(klass_name) rescue nil
      raise ArgumentError, "#{model_and_attribute} does not match a defined Model.attribute" if model.nil? || !model.method_defined?(attribute)

      ActiveStorage.verifier.generate(model_and_attribute)
    end
  end
end
