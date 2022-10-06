require_relative 'train.rb'

# Станция
class Station

  # Имеет название, которое указывается при ее создании
  def initialize(title)
    if title.to_s.length > 0
      @title = title
    else
      raise "Ошибка данных, в названии: #{type}, должно быть хоть какое-то значение"
    end
    @trains = []
  end

  def title
    @title
  end

  # Может принимать поезда (по одному за раз)
  def train_arrive(train)
    if train.is_a?(Train) && !@trains.index(train)
      @trains << train
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: Train, "\
            "или эта станция не следующая по маршруту, уже в списке поездов на станции"
    end
  end

  # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  def trains_get
    @trains
  end

  # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
  def trains_get_by_type(type)
    if Train::TYPES.include?(type)
      @trains.select { |train| train.type_get == type }
    else
      raise "Ошибка данных, неправильный тип состава: #{type}, возможны только: #{Train::TYPES}"
    end
  end

  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def train_depart(train)
    if train.is_a?(Train) && @trains.index(train) && train.curr_station_get == self
      @trains.delete(train)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: Train, "\
            "или эта станция не текущая для поезда, или не в списке поездов на станции"
    end
  end

end
