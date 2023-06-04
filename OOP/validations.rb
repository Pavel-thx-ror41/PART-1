# frozen_string_literal: false

module Validations
  def self.included(base)
    base.extend Extend
  end

  module Extend
    # rubocop:disable all
    def validate(*args, &block)
      @validations ||= []
      @validations.push block_given? ? args.push(block) : args

      unless method_defined?(:valid?)
        define_method(:valid?) do
          validations = self.class.instance_variable_get(:@validations)
          validations ||= self.class.superclass.instance_variable_get(:@validations)

          result = validations.map do |validation|
            if validation[-1].is_a?(Proc)
              # с блоком при объявлении валидации
              unless validation[0].eql?(:self) ?
                       validation[-1].call(self) :
                       validation[-1].call(instance_variable_get("@#{validation[0]}"))
                  message = validation[1][:message]
                  message ||= "Не прошло проверку по блоку: '#{validation[-1].source}'"
                  message
              end
            else
              # блок не передавался при объявлении валидации
              value = instance_variable_get("@#{validation[0]}")
              case validation[1]
              when :present
                'Должно быть не пустым' if value.empty?
              when :format
                if (value =~ validation[2]).nil?
                  message = validation[3][:message]
                  message ||= "Не прошло проверку по шаблону: '#{validation[2]}'"
                  message
                end
              when :type
                "Тип данных '@#{validation[0]}' должен быть '#{validation[2]}', не '#{value.class}'" unless
                  value.is_a?(validation[2])
              else
                raise "Неизвестный параметр для проверки '#{validation[1]}'"
              end
            end
          end

          result.compact.empty? ? true : result.compact.join(' ')
        end
      end

      unless method_defined?(:validate!)
        define_method(:validate!) do
          result = valid?
          return if result.is_a?(TrueClass)

          raise result
        end
      end
    end
    # rubocop:enable all
  end
end
