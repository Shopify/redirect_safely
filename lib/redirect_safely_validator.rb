# frozen_string_literal: true
require 'active_model/validations'

class RedirectSafelyValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless RedirectSafely.safe?(value, options)
  end
end
