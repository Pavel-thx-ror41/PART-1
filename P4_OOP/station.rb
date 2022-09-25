# Класс Station (Станция):
class Station

  # Имеет название, которое указывается при ее создании
  def initialize(title)
    if title.to_s.length > 0
      @title = title
    else
      raise "Ошибка данных, в названии: #{type}, должно быть хоть какое-то значение"
    end
    @trains = nil
  end


  # # Может принимать поезда (по одному за раз)
  # def train_arrive(train)
  #   train.is_a?(Train)
  #   train.route_next_station(train.current_station) == self
  #   # TODO
  # end
  #
  # # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  # def trains_get
  #   @trains
  # end
  #
  # # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
  # def trains_get_by_type(type)
  #   if Types.include?(type)
  #     # TODO by type only
  #     @trains
  #   else
  #     raise "Ошибка данных, неправильный тип состава: #{type}, возможны только: #{Types}"
  #   end
  # end
  #
  # # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  # def train_departure(train)
  #   train.is_a?(Train)
  #   train.route_prev_station(self) == self
  #   # TODO
  # end

end
