# frozen_string_literal: true

module ActiveStorage
  module Validations
    class AttachmentContentTypeValidator < BaseValidator
      AVAILABLE_CHECKS = %i[in not with]

      def self.helper_method_name
        :validates_attachment_content_type
      end

      def check_validity!
        if options_blank?
          raise(
            ArgumentError,
            "You must pass at least one of #{AVAILABLE_CHECKS.join(", ")} to the validator"
          )
        end

        if options_redundant?
          raise(ArgumentError, "Cannot pass both :in and :not")
        end
      end

      private
        def blob_field_name
          :content_type
        end

        def error_key_for(check_name)
          { in: :inclusion, not: :exclusion, with: :inclusion }[check_name.to_sym]
        end

        def options_redundant?
          options.has_key?(:in) && options.has_key?(:not)
        end

        def passes_check?(blob, check_name, check_value)
          case check_name.to_sym
          when :in
            check_value.include?(blob.content_type)
          when :not
            !check_value.include?(blob.content_type)
          when :with
            # TODO: implement check_options_validity from AM::Validators::FormatValidator
            # QUESTION: How best to implement check_options_validity? Going with copy+paste for now.
            check_value = Regexp.new(check_value) if check_value.is_a?(String)
            if check_value.is_a?(Regexp)
              if check_value.source.start_with?("^") || (check_value.source.end_with?("$") && !check_value.source.end_with?("\\$"))
                raise ArgumentError, "The provided regular expression is using multiline anchors (^ or $), " \
                "which may present a security risk. Did you mean to use \\A and \\z, or forgot to add the " \
                ":multiline => true option?"
              end
              check_value.match?(blob.content_type)
            elsif check_value.respond_to?(:call)
              # QUESTION: One would expect the proc or lambda to be called with
              # the Attachable, not the Blob. However, for direct uploads there
              # is no Attachable available. Should we pass the blob instead? Or
              # nil?
              check_value.call(@record || blob).match?(blob.content_type)
            else
              raise ArgumentError, "A regular expression, proc, or lambda must be supplied to :with"
            end
          end
        end
    end

    module HelperMethods
      # Validates the content type of the ActiveStorage attachments. Happens by
      # default on save.
      #
      #   class Employee < ActiveRecord::Base
      #     has_one_attached :avatar
      #
      #     validates_attachment_content_type :avatar, in: %w[image/jpeg audio/ogg]
      #     validates_attachment_content_type :avatar, in: "image/jpeg"
      #   end
      #
      # Configuration options:
      # * <tt>in</tt> - a +Array+ or +String+ of allowable content types
      # * <tt>not</tt> - a +Array+ or +String+ of content types to exclude
      # * <tt>:message</tt> - A custom error message which overrides the
      #   default error message.
      #
      # There is also a list of default options supported by every validator:
      # +:if+, +:unless+, +:on+, +:allow_nil+, +:allow_blank+, and +:strict+.
      # See <tt>ActiveModel::Validations#validates</tt> for more information
      def validates_attachment_content_type(*attributes)
        validates_with AttachmentContentTypeValidator, _merge_attributes(attributes)
      end
    end
  end
end
