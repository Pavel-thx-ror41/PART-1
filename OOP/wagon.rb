require_relative 'manufacturer.rb'

class Wagon
  include Manufacturer

  def self.new(*args, &block) # https://microeducate.tech/in-ruby-whats-the-relationship-between-new-and-initialize-how-to-return-nil-while-initializing/
    new_wagon = super # initialize

    unless new_wagon.valid?
      return RuntimeError.new()
    else
      return new_wagon
    end
  end

  def valid?
    validate!
  rescue RuntimeError => e
    return false
  end

  protected

  def validate!
    raise "Ошибка данных, можно создать только PassengerWagon или CargoWagon" if self.instance_of?(Wagon)

    true
  end
end
