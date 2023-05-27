# frozen_string_literal: false

require_relative 'accessors'

module Manufacturer
  include Accessors

  attr_accessor_with_history :manufacturer
  strong_attr_accessor :origin_country, String, :phoneprefix, Integer
end
