require_relative 'manufacturer.rb'

class Train
  include Manufacturer

  @@trains = []

  def self.find(train)
    @@trains.detect { |t| t == train }
  end

  def initialize(number)
    if self.instance_of?(Train)
      raise "Ошибка данных, можно создать только PassengerTrain или CargoTrain"
    end
    @number = number
    @speed = 0
    @wagons = []
    @route = nil
    @current_station = nil
    @@trains << self
  end

  def number_get
    @number
  end

  def type_get
    self.class.to_s.gsub("Train","").downcase.to_sym
  end

  def speed_set(speed)
    @speed = speed.to_i
  end

  def speed_get
    @speed
  end

  def speed_stop
    @speed = 0
  end

  def wagons_count
    @wagons.count
  end

  def wagon_remove
    @wagons.pop if stopped?
  end

  def wagon_add(wagon)
    @wagons << wagon if stopped? && wagon_is_same_kind?(wagon)
  end

  def route_set(route)
    if route.is_a?(Route) && route.stations_get.first.is_a?(Station)
      @route = route
      @current_station = @route.stations_get.first
    else
      raise "Ошибка данных, тип параметра route: #{route.class}, должен быть Route, с первым элементом Station"
    end
  end

  def route_get
    @route
  end

  def route_move_next_station
    next_station = @route.station_get_next_from(@current_station)
    @current_station = next_station if next_station
  end

  def route_move_prev_station
    prev_station = @route.station_get_prev_from(@current_station)
    @current_station = prev_station if prev_station
  end

  def curr_station_get
    @current_station
  end

  protected

  # будет вызываться у наследников
  def wagon_is_same_kind?(wagon)
    wagon.class.to_s.gsub('Wagon', '') == self.class.to_s.gsub('Train', '')
  end

  # будет вызываться у наследников
  def stopped?
    @speed == 0
  end

end
