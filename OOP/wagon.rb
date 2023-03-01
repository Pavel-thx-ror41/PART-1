require_relative 'manufacturer.rb'

class Wagon
  include Manufacturer
  attr_reader :capacity_total
  attr_reader :capacity_used

  def initialize
    validate!
  end

  def type_get
    self.class.to_s.gsub("Wagon","").downcase.to_sym
  end


  def capacity_take(volume)
    error_message = ""
    error_message << ", нельзя занять больше доступного: #{capacity_free} " if @capacity_used + volume > @capacity_total

    unless error_message.empty?
      error_message = "Ошибка данных" + error_message
      raise error_message
    else
      @capacity_used = @capacity_used + volume
    end
  end

  def capacity_free
    @capacity_total - @capacity_used
  end

  protected

  def validate!
    unless self.instance_of?(PassengerWagon) || self.instance_of?(CargoWagon)
      raise "Ошибка данных, можно создать только PassengerWagon или CargoWagon"
    end

    true
  end
end
