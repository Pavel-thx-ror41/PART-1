# frozen_string_literal: false

# noinspection RubyClassVariableUsageInspection
module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.send :prepend, Initializer # https://stackoverflow.com/a/17498039
  end

  # rubocop:disable Style/ClassVars
  @@instances_counts ||= {}
  # rubocop:enable Style/ClassVars

  module Initializer
    # @@instances_counts ||= {}
    def initialize(*args, &block)
      # @@instances_counts ||= {}
      super(*args, &block)
      register_instance if valid?.is_a?(TrueClass)
    end
  end

  module ClassMethods
    def instances
      class_variable_get(:@@instances_counts)[to_s.to_sym]
    end
  end

  module InstanceMethods
    # @@instances_counts ||= {}

    # проверяем реализацию, используется в тут в initialize
    def valid?
      raise NotImplementedError
    end

    protected

    def register_instance
      register_instance_set(:@@instances_counts)
    end

    def register_instance_set(variable_name)
      instances_counts = self.class.class_variable_get(variable_name)
      instances_counts[self.class.to_s.to_sym] ||= 0
      instances_counts[self.class.to_s.to_sym] += 1
      # self.class.class_variable_set(variable_name, instances_counts ) # by_reference, not by_value
    end
  end
end
