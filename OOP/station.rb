require_relative 'train.rb'
require_relative 'instance_counter.rb'

class Station
  include InstanceCounter

  @@stations = []

  def self.all
    @@stations
  end

  def initialize(title)
    @title = title
    @trains = []
  end

  def self.new(*args, &block) # https://microeducate.tech/in-ruby-whats-the-relationship-between-new-and-initialize-how-to-return-nil-while-initializing/
    new_station = super(*args, &block) # initialize

    new_station.valid?
    @@stations << new_station
    return new_station
  end

  def valid?
    validate!
  end

  def title
    @title
  end

  def train_arrive(train)
    if (train.is_a?(PassengerTrain) || train.is_a?(CargoTrain)) && !@trains.index(train)
      @trains << train
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: PassengerTrain или CargoTrain, "\
            "или эта станция не следующая по маршруту, уже в списке поездов на станции"
    end
  end

  def trains_get
    @trains
  end

  def trains_get_by_type(type)
    @trains.select { |train| train.type_get == type }
  end

  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def train_depart(train)
    if (train.is_a?(PassengerTrain) || train.is_a?(CargoTrain)) && @trains.index(train) && train.curr_station_get == self
      @trains.delete(train)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: PassengerTrain или CargoTrain, "\
            "или эта станция не текущая для поезда, или не в списке поездов на станции"
    end
  end

  private

  STATION_TITLE_FORMAT = /^(\d|[A-ZА-Я]|Ё| ){2,32}$/i
  def validate!
    raise "Ошибка. Допустимый формат: от 2-х до 32 буквы, цифры, пробел" unless @title =~ STATION_TITLE_FORMAT
    true
  end
end
