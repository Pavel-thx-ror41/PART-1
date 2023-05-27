# frozen_string_literal: false

module Accessors
  def self.included(base)
    base.extend Extend
    # base.send :prepend, Prep # https://stackoverflow.com/a/17498039
    # base.send :include, Incl
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

    # 1 binding.pry # A ClassMeth
    # class Module
    #   def _____Extend_Module_Method_____
    #     puts '_____Extend_Module_Method_____'
    #   end
    #
    #   def self._____Extend_Module_Self_Method_____
    #     puts 'Module   self._____Extend_Module_Self_Method_____ ++++++++++'
    #   end
    # end
    # 2 binding.pry # A ClassMeth Module+

    # def self._____Extend_Self_Method_____
    #   puts 'Accessors::Extend   self._____Extend_Self_Method_____ ++++++++++'
    # end
    # 3 binding.pry # A ClassMeth Meths+
  end

  # module Prep
  #   # instance.methods.sort
  #
  #   def attr_accessor_with_p
  #     puts 'attr_accessor_with_p'
  #   end
  #
  #   # def self._____prep_self_____
  #   #   puts 'prep_____'
  #   # end
  # end

  # module Incl
  #   # instance.methods.sort
  #
  #   def attr_accessor_with_i
  #     puts 'attr_accessor_with_i'
  #   end
  #
  #   # def self._____incl_self_____
  #   #   puts 'incl_____'
  #   # end
  # end
end
