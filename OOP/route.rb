require_relative 'instance_counter.rb'

class Route
  include InstanceCounter

  def initialize(from, to)
    @stations = []
    @stations << from
    @stations << to
  end

  def self.new(*args, &block) # https://microeducate.tech/in-ruby-whats-the-relationship-between-new-and-initialize-how-to-return-nil-while-initializing/
    new_route = super # initialize

    unless new_route.valid?
      return RuntimeError.new()
    else
      return new_route
    end
  end

  def valid?
    validate!
  rescue RuntimeError => e
    return false
  end

  def title
    "#{@stations.first.title} - #{@stations.last.title}"
  end

  def station_insert(station, before)
    if station.is_a?(Station) && before.is_a?(Station) && @stations.first != before && !@stations.index(station)
      @stations.insert(@stations.index(before), station)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{[station.class, before.class]}, требуется: Station, "\
            "или попытка вставить перед первой станцией, можно только после и если уже не в списке"
    end
  end

  def station_remove(station)
    if station.is_a?(Station) && @stations.first != station && @stations.last != station && @stations.index(station)
      @stations.delete(station)
    else
      raise "Ошибка данных, не правильный тип параметров #{station.class},"\
            " возможно только: Station. Также, нельзя удалять конечные станции"
    end
  end

  def stations_get
    @stations
  end

  def station_get_next_from(from_station)
    from_station_index = @stations.index(from_station)
    @stations[from_station_index + 1] if from_station_index
  end

  def station_get_prev_from(from_station)
    from_station_index = @stations.index(from_station)
    @stations[from_station_index - 1] if from_station_index && from_station_index > 0
  end

  protected

  def validate!
    raise "Ошибка данных, неправильный тип(ы) параметра(ов) #{[@stations.first.class, @stations.last.class]}, " + \
          "возможно только: Station" unless @stations.first.is_a?(Station) && @stations.last.is_a?(Station)
    raise "Ошибка данных, начальная и конечная " + \
          "станции должны быть разными" if @stations.first.object_id == @stations.last.object_id

    true
  end
end
