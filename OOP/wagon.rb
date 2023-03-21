# frozen_string_literal: false

require_relative 'manufacturer'

# Abstract Wagon
class Wagon
  include Manufacturer
  attr_reader :capacity_total, :capacity_used

  def initialize
    # validate!
    raise 'Ошибка данных, можно создать только PassengerWagon или CargoWagon'
  end

  def type_get
    self.class.to_s.gsub('Wagon', '').downcase.to_sym
  end

  def capacity_take(volume)
    error_message = ''
    error_message << ", нельзя занять больше доступного: #{capacity_free} " if @capacity_used + volume > @capacity_total

    if error_message.empty?
      @capacity_used += volume
    else
      error_message = "Ошибка данных #{error_message}"
      raise error_message
    end
  end

  def capacity_free
    @capacity_total - @capacity_used
  end

  # protected
  #
  # def validate!
  #   unless instance_of?(PassengerWagon) || instance_of?(CargoWagon)
  #     raise 'Ошибка данных, можно создать только PassengerWagon или CargoWagon'
  #   end
  #
  #   true
  # end
end
