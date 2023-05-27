# frozen_string_literal: false

require_relative 'accessors'

module Manufacturer
  include Accessors

  attr_accessor_with_history :manufacturer
end
