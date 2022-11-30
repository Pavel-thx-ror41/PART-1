require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
require_relative 'wagon.rb'
require_relative 'cargo_train.rb'
require_relative 'cargo_wagon.rb'
require_relative 'passenger_train.rb'
require_relative 'passenger_wagon.rb'

class RailWay
  attr_reader :stations
  # @station_not_in_route
  attr_reader :routes
  attr_reader :trains

  def initialize(seed: false)
    @stations = []
    @routes = []
    @trains = []
    seed() if seed
  end

  def status
    result_string = "\n"
    result_string << "\n" << " \033[1mСтанции\033[0m"
    self.stations.each do |station|
      result_string << "\n" << "  #{station.title}" +
                               "   (поезда на станции: #{station.trains_get.map(&:number_get).join(", ")})"
    end

    result_string << "\n"
    result_string << "\n" << " \033[1mМаршруты\033[0m"
    self.routes.each do |route|
      result_string << "\n" << "  #{route.title}   (#{route.stations_get.map(&:title).join(", ")})"
    end

    result_string << "\n"
    result_string << "\n" << " \033[1mПоезда\033[0m"
    self.trains.each do |train|
      result_string << "\n" << "  #{train.number_get} #{train.route_get&.title}" +
                               "   (#{train.type_get.to_s.gsub("cargo", "ГРУЗОВОЙ").gsub("passenger", "ПАССАЖИРСКИЙ")}" +
                               ", #{train.wagons_count} вагонов, на станции #{train.curr_station_get&.title})"
    end
    result_string
  end

  private

  # вызывается только из initialize
  def seed
    self.stations << Station.new('Москва')
    self.stations << Station.new('Воронеж')
    self.stations << Station.new('Ростов на Дону')
    self.stations << Station.new('Краснодар')
    self.stations << Station.new('Горячий ключ')
    # @station_not_in_route = Station.new('Ильская')


    route = Route.new(stations.first, stations.last)

    route.station_insert(stations[1], stations.last)
    route.station_insert(stations[2], stations.last)
    route.station_insert(stations[3], stations.last)
    route.station_remove(stations[3])
    route.station_remove(stations[2])
    route.station_remove(stations[1])

    route.station_insert(stations[1], stations.last)
    route.station_insert(stations[2], stations.last)
    route.station_insert(stations[3], stations.last)
    self.routes << route


    route = Route.new(stations[2], stations[4])
    route.station_insert(stations[3], stations[4])
    self.routes << route

    route = Route.new(stations[2], stations[4])
    route.station_insert(stations[3], stations[4])
    self.routes << route


    train = CargoTrain.new("01А-0А")
    if train.is_a?(Train)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train
    end

    train = CargoTrain.new("02Б-0Б")
    if train.is_a?(Train)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train
    end

    train = CargoTrain.new("03В-АВ")
    if train.is_a?(Train)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train

      train.route_set(routes.first)
      train.curr_station_get.train_arrive(train)
    end

    train = PassengerTrain.new("04Г-ЖГ")
    if train.is_a?(Train)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      self.trains << train

      train.route_set(routes.last)
      train.curr_station_get.train_arrive(train)
    end

    train = CargoTrain.new("05Д-4Д")
    if train.is_a?(Train)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train

      train.route_set(routes.first)
      train.curr_station_get.train_arrive(train)
    end

    train = PassengerTrain.new("06Е-АЕ")
    if train.is_a?(Train)
      self.trains << train

      train.manufacturer = "manufacturer_caption"
      raise "Ошибка проверки доработок task225829 manufacturer" if train.manufacturer != "manufacturer_caption"
    end

    raise "Ошибка проверки доработок task225829" unless Train.new("987-ZA").instance_of?(RuntimeError)

    raise "Ошибка проверки доработок task225829" if (
      Train.find(trains[2]).number_get != trains[2].number_get ||
      # Station.all.count != 5 ||
      # Station.instances != 5 ||
      # Route.instances != 3 ||
      CargoTrain.instances != 4 ||
      PassengerTrain.instances != 2
    )
  end
end
