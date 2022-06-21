# frozen_string_literal: true

module ActiveStorage
  module DirectUploadsHelper
    # Requires an instance of a Model and an attribute which allows us to know
    # what validations to run. Supports persisted and non-persisted model
    # instances so that direct uploads can be made for new records before
    # they've been persisted.
    #
    # For example, regardless of whether the passed in model is persisted,
    # `@user, :avatar` or `User.new, :avatar`, ActiveStorage will run the
    # ActiveStorage related validations defined for the User model's avatar
    # attribute. The passed in model instance comes into play when it's passed
    # to any procs defined for those validations.
    #
    #   class User < ApplicationRecord
    #     validates :avatar, attachment_content_type: { with: Proc.new { |user| user.persisted? ? %w[image/jpeg image/png image/gif] : %w[image/jpeg] } }
    #   end
    #
    # Returns a signed string
    def rails_direct_uploads_signed_model_and_attribute(model, attribute)
      raise ArgumentError, "#{model.model_name} does not have an attribute named #{attribute}" if !model.respond_to?(attribute)

      ActiveStorage.verifier.generate("#{model.to_global_id}--#{attribute}")
    rescue URI::GID::MissingModelIdError
      ActiveStorage.verifier.generate("#{model.model_name}--#{attribute}")
    end
  end
end
