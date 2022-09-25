# Класс Station (Станция):
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


  # Может принимать поезда (по одному за раз)
  def train_arrive(train)
    if train.is_a?(Train) && !@trains.index(train) && train.route_get_next_station == self
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

  # # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
  # def trains_get_by_type(type)
  #   if Route.Types.include?(type)
  #     # TODO by type only
  #     @trains
  #   else
  #     raise "Ошибка данных, неправильный тип состава: #{type}, возможны только: #{Types}"
  #   end
  # end

  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def train_depart(train)
    if train.is_a?(Train) && @trains.index(train) && train.route_get_curr_station == self
      @trains.delete(train)
    else
      raise "Ошибка данных. "\
            "Неправильный тип параметров: #{train.class}, требуется: Train, "\
            "или эта станция не текущая для поезда, или не в списке поездов на станции"
    end
  end

end
