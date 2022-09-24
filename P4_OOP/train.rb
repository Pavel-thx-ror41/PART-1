require_relative 'route.rb'
require_relative 'station.rb'

# Класс Train (Поезд)
class Train
  # возможные типы поездов (грузовой, пассажирский)
  Types = [:cargo, :passenger]

  def initialize(number, type)
    if Types.include?(type)
      @type = type
    else
      raise "Ошибка данных, неправильный тип создаваемого состава: #{type}, возможны только: #{Types}"
    end
    @number = number        # номер поезда (произвольная строка)

    @speed = 0
    @wagons_count = 0       # количество вагонов
    @route = nil            # Route
    @current_station = nil  # Station
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
    if route.is_a?(Route) && route.first.is_a?(Station)
      @route = route
      @current_station = @route.first
    else
      raise "Ошибка данных, тип параметра route: #{route.class}, должен быть Route, с первым элементом Station"
    end
  end

  # Может перемещаться между станциями, указанными в маршруте.
  # Перемещение возможно вперед и назад, но только на 1 станцию за раз.
  def route_move_next_station
    # TODO after Route
    @current_station = @route.next_from(@current_station)
  end
  def route_move_prev_station
    # TODO after Route
    @current_station = @route.prev_from(@current_station)
  end

  # Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
  def route_get_next_station
    # TODO after Route
    @route.next_from(@current_station)
  end
  def route_get_curr_station
    @current_station
  end
  def route_get_prev_station
    # TODO after Route
    @route.prev_from(@current_station)
  end

end
