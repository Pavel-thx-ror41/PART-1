# frozen_string_literal: false

module Accessors
  def self.included(base)
    base.extend Extend
  end

  module Extend
    def attr_accessor_with_history(*args)
      args.each do |a|
        var_name = "@#{a}_history".to_sym

        define_method("#{a}=".to_sym) do |new_val|
          curr_values = instance_variable_get(var_name)
          curr_values ||= []
          curr_values.push(new_val)
          instance_variable_set(var_name, curr_values)
        end

        define_method(a) do
          instance_variable_get(var_name)&.last
        end

        define_method("#{a}_history".to_sym) do
          instance_variable_get(var_name)
        end
      end
    end
  end
end
