require_relative 'train.rb'

class Station

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

  def train_arrive(train)
    if train.is_a?(Train) && !@trains.index(train)
      @trains << train
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: Train, "\
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
    if train.is_a?(Train) && @trains.index(train) && train.curr_station_get == self
      @trains.delete(train)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: Train, "\
            "или эта станция не текущая для поезда, или не в списке поездов на станции"
    end
  end

end
