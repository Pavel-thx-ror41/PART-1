# Класс Route (Маршрут)
class Route
  # Имеет начальную и конечную станцию, а также список промежуточных станций.
  # Начальная и конечная станции указываютсся при создании маршрута, а промежуточные могут добавляться между ними.
  def initialize(from, to)
    if from.is_a?(Station) && to.is_a?(Station)
      @stations = []
      @stations << from
      @stations << to
    else
      raise "Ошибка данных, неправильный тип параметров #{[from.class, to.class]}, возможно только: Station"
    end
  end

  # Может добавлять промежуточную станцию в список
  def station_insert(station, before)
    if station.is_a?(Station) && before.is_a?(Station) && @stations.first != before && !@stations.index(station)
      @stations.insert(@stations.index(before), station)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{[station.class, before.class]}, требуется: Station, "\
            "или попытка вставить перед первой станцией, можно только после и если уже не в списке"
    end
  end

  # Может удалять промежуточную станцию из списка
  def station_remove(station)
    if station.is_a?(Station) && @stations.first != station && @stations.last != station && @stations.index(station)
      @stations.delete(station)
    else
      raise "Ошибка данных, не правильный тип параметров #{station.class},"\
            " возможно только: Station. Также, нельзя удалять конечные станции"
    end
  end

  # Может выводить список всех станций по-порядку от начальной до конечной
  def stations_get
    @stations
  end

  # Следующая от указанной станции
  def stations_get_next_from()
    #@stations
    # TODO 1st
  end

  # Следующая от указанной станции
  def stations_get_prev_from()
    #@stations
    # TODO 1st
  end

end
