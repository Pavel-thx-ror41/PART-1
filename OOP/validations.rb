# frozen_string_literal: false

module Validations
  def self.included(base)
    base.extend ClassMethods
    # base.send :include, InstanceMethods
    base.include InstanceMethods
  end

  module ClassMethods
    attr_reader :validations

    # Usage:
    #   validate :variable_name(or :self), :method [, :params, {:message => "..."}]
    #   validate :variable_name(or :self)[, :message] do { |variable_name| block }
    def validate(*args, &block)
      @validations ||= []
      @validations.push [*args, block].compact
    end
  end

  module InstanceMethods
    protected

    # использовать: valid?.is_a?(TrueClass)
    def valid?
      validations = self.class.validations
      validations ||= self.class.superclass.validations

      result = validations.map do |validation|
        attr_value = validation[0].eql?(:self) ? self : instance_variable_get("@#{validation[0]}")

        if validation[-1].is_a?(Proc) # валидация с блоком (как обычно: true,... / false,nil )
          unless validation[-1].call attr_value
            error_message = validation[1][:message]
            error_message ||= "Не прошло проверку по блоку: '#{validation[-1].source}'"
            error_message
            # возвращаем nil/"error message"
          end

        else # валидация методом, без блока
          validation_result = send validation[1], validation, attr_value # методы возвращают: true/"error message"
          validation_result.is_a?(TrueClass) ? nil : validation_result
          # возвращаем nil/"error message"
        end

        # возвращаем в result например: [nil, "error message", ...]
      end

      # возвращаем true (TrueClass), либо список ошибок (String)
      result.compact.empty? ? true : result.compact.join(' ')
    end

    def validate!
      result = valid?
      return if result.is_a?(TrueClass)

      raise result
    end

    def present(_validation, value)
      return 'Должно быть не пустым' if value.empty?

      true
    end

    def type(validation, value)
      return "Тип данных '@#{validation[0]}' должен быть '#{validation[2]}', не '#{value.class}'" unless
        value.is_a?(validation[2])

      true
    end

    def format(validation, value)
      if (value =~ validation[2]).nil?
        message = validation[3][:message]
        message ||= "Не прошло проверку по шаблону: '#{validation[2]}'"
        return message
      end

      true
    end
  end
end
