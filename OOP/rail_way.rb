# frozen_string_literal: false

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_train'
require_relative 'cargo_wagon'
require_relative 'passenger_train'
require_relative 'passenger_wagon'

class RailWay
  attr_reader :stations, :routes, :trains

  # @station_not_in_route

  def initialize(do_seed: false)
    @stations = []
    @routes = []
    @trains = []
    seed if do_seed
  end

  def status
    result_string = "\n" << " \033[1mСтанции\033[0m"

    # TODO: extract method
    stations.each do |station|
      station_trains = []
      station.trains_get.map do |train|
        station_trains << "#{train.number_get}" \
                          " #{train.type_get.to_s.gsub('cargo', 'ГРУЗ').gsub('passenger', 'ПАС')}" \
                          " #{train.route_get&.title}" \
                          " вагонов:#{train.wagons_count}"
      end

      result_string << "\n" << "  #{station.title} поезда на станции: #{station_trains.join('; ')}"
    end

    result_string << '' # TODO: ??
    result_string << "\n" << " \033[1mМаршруты\033[0m"

    # TODO: extract method
    routes.each do |route|
      result_string << "\n" << "  #{route.title}   (#{route.stations_get.map(&:title).join(', ')})"
    end

    result_string << '' # TODO: ??
    result_string << "\n" << " \033[1mПоезда\033[0m"
    # TODO: extract method
    trains.each do |train|
      train_wagons_caps = [0, 0]
      train_wagons = []
      train.wagons_map do |wagon|
        train_wagons_caps[0] += wagon.capacity_used
        train_wagons_caps[1] += wagon.capacity_free
        train_wagons << "№#{train_wagons.size + 1}" \
                        " #{wagon.type_get.to_s.gsub('cargo', 'ГРУЗ').gsub('passenger', 'ПАС')}" \
                        " св.:#{wagon.capacity_free}" \
                        " з.:#{wagon.capacity_used}"
      end
      result_string << "\n" << "  #{train.number_get}" \
                               " '#{train.route_get&.title}'" \
                               " #{train.type_get.to_s.gsub('cargo', 'ГРУЗОВОЙ').gsub('passenger', 'ПАССАЖИРСКИЙ')}" \
                               ", на станции: '#{train.curr_station_get&.title}'" \
                               ", вагоны: #{train.wagons_count}шт." \
                               " доступно: #{train_wagons_caps[1]} занято #{train_wagons_caps[0]}" \
                               " #{train.type_get.to_s.gsub('cargo', 'тонн').gsub('passenger', 'мест')}" \
                               "\r\n         (выгоны: #{train_wagons.join('; ')})"
    end

    result_string
  end

  private

  # вызывается только из initialize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/SuppressedException
  # rubocop:disable Style/RescueStandardError
  def seed
    ['Москва', 'Воронеж', 'Ростов на Дону', 'Краснодар', 'Горячий ключ'].each do |station_caption|
      stations << Station.new(station_caption)
    end
    # @station_not_in_route = Station.new('Ильская')

    station = nil
    begin station = Station.new('М'); rescue; end
    raise 'Ошибка проверки доработок Station. Название Станции должно быть от 2-х до 32 буквы, цифры, пробел' if station

    raise 'Ошибка проверки доработок Station (instance_counter)' if
      Station.instances != 5 ||
      Station.all.count != 5 ||
      stations.count != 5

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
      routes << route

      route = Route.new(stations[2], stations[4])
      route.station_insert(stations[3], stations[4])
      routes << route

      route = Route.new(stations[1], stations[4])
      route.station_insert(stations[3], stations[4])
      routes << route
    rescue RuntimeError => e
      puts e
      exit
    end

    raise 'Ошибка проверки доработок Route (instance_counter)' if
      Route.instances != 3 ||
      routes.count != 3

    wagon = nil
    begin wagon = Wagon.new; rescue; end
    raise 'Ошибка проверки доработок Wagon. Можно создать только CargoWagon или PassengerWagon' if wagon

    begin
      train = PassengerTrain.new('01А-0А')
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      trains << train

      train = CargoTrain.new('02Б-0Б')
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      trains << train

      train = CargoTrain.new('03В-АВ')
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      trains << train
      train.route_set(routes.first)

      train = PassengerTrain.new('04Г-ЖГ')
      train.wagon_add(PassengerWagon.new)
      train.wagon_add(PassengerWagon.new)
      trains << train
      train.route_set(routes.last)

      train = CargoTrain.new('05Д-4Д')
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      train.wagon_add(CargoWagon.new)
      trains << train
      train.route_set(routes.first)

      train = PassengerTrain.new('06Е-АЕ')
      trains << train
      train.manufacturer = 'manufacturer_caption'
      raise 'Ошибка проверки доработок Manufacturer' if train.manufacturer != 'manufacturer_caption'
    rescue RuntimeError => e
      puts e
      exit
    end

    raise 'Ошибка проверки доработок Wagons (полезная нагрузка) начальные значения' if
      trains[0].wagons_map(&:capacity_free).uniq.first != 36 ||
      trains[0].wagons_map(&:capacity_used).uniq.first != 0 ||
      (trains[1].wagons_map(&:capacity_free).uniq.first * 10).round.to_i != 500 ||
      (trains[1].wagons_map(&:capacity_used).uniq.first * 10).round.to_i != 0 ||
      trains[3].wagons_map(&:capacity_free).uniq.first != 36 ||
      trains[3].wagons_map(&:capacity_used).uniq.first != 0 ||
      (trains[2].wagons_map(&:capacity_free).uniq.first * 10).round.to_i != 500 ||
      (trains[2].wagons_map(&:capacity_used).uniq.first * 10).round.to_i != 0

    begin
      trains[0].wagons_map { |w| w.capacity_take(10) }
      trains[0].wagons_map(&:capacity_take_one)
      trains[1].wagons_map { |w| w.capacity_take(10.0) }
    rescue RuntimeError => e
      puts 'Ошибка проверки доработок Wagons (полезная нагрузка) ожидаемое поведение'
      puts e
      exit
    end

    begin trains[3].wagons_map { |w| w.capacity_take(37) }; rescue; end
    begin trains[2].wagons_map { |w| w.capacity_take(50.1) }; rescue; end
    raise 'Ошибка проверки доработок Wagons (полезная нагрузка) проверка capacity_take' if
      trains[0].wagons_map(&:capacity_free).uniq.first != 25 ||
      trains[0].wagons_map(&:capacity_used).uniq.first != 11 ||
      (trains[1].wagons_map(&:capacity_free).uniq.first * 10).round.to_i != 400 ||
      (trains[1].wagons_map(&:capacity_used).uniq.first * 10).round.to_i != 100 ||
      trains[3].wagons_map(&:capacity_free).uniq.first != 36 ||
      trains[3].wagons_map(&:capacity_used).uniq.first != 0 ||
      (trains[2].wagons_map(&:capacity_free).uniq.first * 10).round.to_i != 500 ||
      (trains[2].wagons_map(&:capacity_used).uniq.first * 10).round.to_i != 0

    train = nil
    begin train = Train.new('987-ZA'); rescue; end
    raise 'Поезд должен быть PassengerTrain или CargoTrain, не Train' if train

    raise 'Ошибка проверки доработок Train' if
      Train.find(trains[2]).number_get != trains[2].number_get ||
      CargoTrain.instances != 3 ||
      PassengerTrain.instances != 3 ||
      trains.count != 6

    raise 'Ошибка проверки доработок Station.trains_map' if
      stations.first.trains_map { |t| "№#{t.number_get}" }.join(' ') != '№03В-АВ №05Д-4Д'

    raise 'Ошибка проверки доработок Train.wagons_map' if
      stations.first.trains_get.first.wagons_map { |w| "Class#{w.class}" }.uniq.first != 'ClassCargoWagon'
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/SuppressedException
  # rubocop:enable Style/RescueStandardError
end
