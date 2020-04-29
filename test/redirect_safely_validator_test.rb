# frozen_string_literal: true
require 'test_helper'
require 'active_model/translation'

class RedirectSafelyValidatorTest < ActiveSupport::TestCase
  class BaseTestClass
    attr_accessor :redirect_to
    include ActiveModel::Validations
    def initialize(redirect_to)
      self.redirect_to = redirect_to
    end
  end

  class TestModelWithDefaults < BaseTestClass
    validates :redirect_to, redirect_safely: true
  end

  test "/ is a valid redirect when no options are given" do
    assert TestModelWithDefaults.new('/').valid?
  end

  test 'nil and blank are not accepted by default' do
    refute TestModelWithDefaults.new(nil).valid?
    refute TestModelWithDefaults.new('').valid?
  end

  class TestModelWithAllowNil < BaseTestClass
    validates :redirect_to, redirect_safely: { allow_nil: true }
  end

  test 'nil is allowed with allow_nil' do
    assert TestModelWithAllowNil.new(nil).valid?
    refute TestModelWithAllowNil.new('').valid?
  end

  class TestModelWithAllowBlank < BaseTestClass
    validates :redirect_to, redirect_safely: { allow_blank: true }
  end

  test 'nil and blank are allowed with allow_blank' do
    assert TestModelWithAllowBlank.new(nil).valid?
    assert TestModelWithAllowBlank.new('').valid?
  end
end
