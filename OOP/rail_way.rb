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
    result_string = ""
    result_string << "\n" << " \033[1mСтанции\033[0m"
    self.stations.each do |station|
      result_string << "\n" << "  #{station.title}" +
                               "   (поезда на станции: #{station.trains_get.map(&:number_get).join(", ")})"
    end

    result_string << ""
    result_string << "\n" << " \033[1mМаршруты\033[0m"
    self.routes.each do |route|
      result_string << "\n" << "  #{route.title}   (#{route.stations_get.map(&:title).join(", ")})"
    end

    result_string << ""
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
    stations << Station.new('Москва')
    stations << Station.new('Воронеж')
    stations << Station.new('Ростов на Дону')
    stations << Station.new('Краснодар')
    stations << Station.new('Горячий ключ')
    # @station_not_in_route = Station.new('Ильская')

    begin
      station = Station.new('М')
    rescue RuntimeError => e
    end
    raise "Ошибка проверки доработок Station. Название Станции должно быть " + \
          "от 2-х до 32 буквы, цифры, пробел" if station

    raise "Ошибка проверки доработок Station" if (
      Station.instances != 5 ||
      Station.all.count != 5 ||
      stations.count != 5
    )


    begin
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

      route = Route.new(stations[1], stations[4])
      route.station_insert(stations[3], stations[4])
      self.routes << route

    rescue RuntimeError => e
      puts e
      exit
    end

    raise "Ошибка проверки доработок Route" if (
        Route.instances != 3 ||
        routes.count != 3
    )


    begin
      wagon = nil
      wagon = Wagon.new
    rescue RuntimeError => e
    end
    raise "Ошибка проверки доработок Wagon. Можно создать только CargoWagon или PassengerWagon" if wagon


    begin
      train = PassengerTrain.new("01А-0А")
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      self.trains << train

      train = CargoTrain.new("02Б-0Б")
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train

      train = CargoTrain.new("03В-АВ")
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train
      train.route_set(routes.first)

      train = PassengerTrain.new("04Г-ЖГ")
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      self.trains << train
      train.route_set(routes.last)

      train = CargoTrain.new("05Д-4Д")
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      self.trains << train
      train.route_set(routes.first)

      train = PassengerTrain.new("06Е-АЕ")
      self.trains << train
      train.manufacturer = "manufacturer_caption"
      raise "Ошибка проверки доработок Manufacturer" if train.manufacturer != "manufacturer_caption"

    rescue RuntimeError => e
      puts e
      exit
    end


    raise "Ошибка проверки доработок Wagons (полезная нагрузка) начальные значения" if (
      self.trains[0].wagons_map { |w| w.capacity_free }.uniq.first != 36 ||
      self.trains[0].wagons_map { |w| w.capacity_used }.uniq.first != 0 ||
      self.trains[1].wagons_map { |w| w.capacity_free }.uniq.first != 50.0 ||
      self.trains[1].wagons_map { |w| w.capacity_used }.uniq.first != 0.0 ||

      self.trains[3].wagons_map { |w| w.capacity_free }.uniq.first != 36 ||
      self.trains[3].wagons_map { |w| w.capacity_used }.uniq.first != 0 ||
      self.trains[2].wagons_map { |w| w.capacity_free }.uniq.first != 50.0 ||
      self.trains[2].wagons_map { |w| w.capacity_used }.uniq.first != 0.0
    )

    begin
      self.trains[0].wagons_map { |w| w.capacity_take(10) }
      self.trains[0].wagons_map { |w| w.capacity_take_one }
      self.trains[1].wagons_map { |w| w.capacity_take(10.0) }
    rescue RuntimeError => e
      puts "Ошибка проверки доработок Wagons (полезная нагрузка) ожидаемое поведение"
      puts e
      exit
    end

    begin
      self.trains[3].wagons_map { |w| w.capacity_take(37) }
    rescue RuntimeError => e
    end

    begin
      self.trains[2].wagons_map { |w| w.capacity_take(50.1) }
    rescue RuntimeError => e
    end

    raise "Ошибка проверки доработок Wagons (полезная нагрузка) проверка capacity_take" if (
      self.trains[0].wagons_map { |w| w.capacity_free }.uniq.first != 25 ||
      self.trains[0].wagons_map { |w| w.capacity_used }.uniq.first != 11 ||
      self.trains[1].wagons_map { |w| w.capacity_free }.uniq.first != 40.0 ||
      self.trains[1].wagons_map { |w| w.capacity_used }.uniq.first != 10.0 ||

      self.trains[3].wagons_map { |w| w.capacity_free }.uniq.first != 36 ||
      self.trains[3].wagons_map { |w| w.capacity_used }.uniq.first != 0 ||
      self.trains[2].wagons_map { |w| w.capacity_free }.uniq.first != 50.0 ||
      self.trains[2].wagons_map { |w| w.capacity_used }.uniq.first != 0.0
    )


    begin
      train = nil
      train = Train.new("987-ZA")
    rescue RuntimeError => e
    end
    raise "Поезд должен быть PassengerTrain или CargoTrain, не Train" if train

    raise "Ошибка проверки доработок Train" if (
      Train.find(trains[2]).number_get != trains[2].number_get ||
      CargoTrain.instances != 3 ||
      PassengerTrain.instances != 3 ||
      trains.count != 6
    )

    raise "Ошибка проверки доработок Station.trains_map" if (
      stations.first.trains_map { |train| "№#{train.number_get}" }.join(" ") != "№03В-АВ №05Д-4Д"
    )

    raise "Ошибка проверки доработок Train.wagons_map" if (
      stations.first.trains_get.first.wagons_map { |wagon| "Class#{wagon.class.to_s}" }.uniq.first != "ClassCargoWagon"
    )

  end
end
