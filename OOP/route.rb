# frozen_string_literal: false

require_relative 'instance_counter'

class Route
  include InstanceCounter

  def initialize(from, to)
    @stations = []
    @stations << from
    @stations << to

    validate!
  end

  # используется в InstanceCounter в initialize
  def valid?
    validate!
  end

  def title
    "#{@stations.first.title} - #{@stations.last.title}"
  end

  def station_insert(station, index)
    if station.is_a?(Station) && index.is_a?(Station) && @stations.first != index && !@stations.index(station)
      @stations.insert(@stations.index(index), station)
    else
      raise 'Ошибка данных. ' \
            "Неправильный тип параметров: #{[station.class, index.class]}, требуется: Station, " \
            'или попытка вставить перед первой станцией, можно только после и если уже не в списке'
    end

    self
  end

  def stations_insert(stations, index)
    stations.each { |station| station_insert(station, index) }

    self
  end

  def station_remove(station)
    error_message = ''
    error_message << ', нельзя удалять конечные станции' if @stations.first == station || @stations.last == station

    error_message << ', станция не найдена в списке' unless @stations.index(station)
    unless station.is_a?(Station)
      error_message << ", не правильный тип параметров #{station.class}, возможно только: Station"
    end

    if error_message.empty?
      @stations.delete(station)
    else
      error_message = "Ошибка данных #{error_message}"
      raise error_message
    end

    self
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
    @stations[from_station_index - 1] if from_station_index&.positive?
  end

  protected

  def validate!
    unless @stations.first.is_a?(Station) && @stations.last.is_a?(Station)
      raise "Ошибка данных, неправильный тип(ы) параметра(ов) #{[@stations.first.class, @stations.last.class]}, " \
            'возможно только: Station'
    end

    raise 'Ошибка данных, начальная и конечная станции должны быть разными' if @stations.first.equal?(@stations.last)

    true
  end
end
