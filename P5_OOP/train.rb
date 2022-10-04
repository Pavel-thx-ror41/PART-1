# Неопределённый Поезд
class Train
  # возможные типы поездов (грузовой, пассажирский)
  TYPES = [:cargo, :passenger]

  def initialize(number, type)
    raise 'Можно создавать только определённый поезд' if self.class == Train
    # можно и не определённый, до добавления первого вагона

    if TYPES.include?(type)
      @type = type
    else
      raise "Ошибка данных, неправильный тип создаваемого состава: #{type}, возможны только: #{TYPES}"
    end
    @number = number        # номер поезда (произвольная строка)

    @speed = 0
    @wagons_count = 0       # количество вагонов
    @route = nil            # Route
    @current_station = nil  # Station
  end

  def type_get
    @type
  end

  # Может набирать скорость
  def speed_set(speed)
    @speed = speed.to_i
  end

  # Может возвращать текущую скорость
  def speed_get
    @speed
  end

  # Может тормозить (сбрасывать скорость до нуля)
  def speed_stop
    @speed = 0
  end


  # Может возвращать количество вагонов
  def wagons_count
    @wagons_count
  end

  # Может прицеплять/отцеплять вагоны
  # (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов).
  # Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
  def wagon_add
    @wagons_count +=1 if @speed == 0
  end
  def wagon_remove
    @wagons_count -=1 if (@speed == 0) && (@wagons_count > 0)
  end


  # Может принимать маршрут следования (объект класса Route).
  # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте.
  def route_set(route)
    if route.is_a?(Route) && route.stations_get.first.is_a?(Station)
      @route = route
      @current_station = @route.stations_get.first
    else
      raise "Ошибка данных, тип параметра route: #{route.class}, должен быть Route, с первым элементом Station"
    end
  end

  # Может перемещаться между станциями, указанными в маршруте.
  # Перемещение возможно вперед и назад, но только на 1 станцию за раз.
  def route_move_next_station
    @current_station = @route.station_get_next_from(@current_station)
  end
  def route_move_prev_station
    @current_station = @route.station_get_prev_from(@current_station)
  end

  # Возвращает следующую, текущую, предыдущую станцию, на основе маршрута
  def route_get_next_station
    @route.station_get_next_from(@current_station)
  end
  def curr_station_get
    @current_station
  end
  def route_get_prev_station
    @route.station_get_prev_from(@current_station)
  end

end
