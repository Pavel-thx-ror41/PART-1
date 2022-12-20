require_relative 'manufacturer.rb'

class Wagon
  include Manufacturer

  def initialize
    validate!
  end

  protected

  def validate!
    if !self.instance_of?(PassengerWagon) && !self.instance_of?(CargoWagon)
      raise "Ошибка данных, можно создать только PassengerWagon или CargoWagon"
    end

    true
  end
end
