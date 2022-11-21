require_relative 'instance_counter.rb'

class Route
  include InstanceCounter

  def initialize(from, to)
    if from.is_a?(Station) && to.is_a?(Station) && from.object_id != to.object_id
      @stations = []
      @stations << from
      @stations << to
    else
      raise "Ошибка данных, неправильный тип параметров #{[from.class, to.class]}, возможно только: Station"
    end
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

end
