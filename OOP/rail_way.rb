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
    status_stations << status_routes << status_trains
  end

  private

  def status_trains
    result_string = "\n" << " \033[1mПоезда\033[0m"
    @trains.each do |train|
      result_string << "\n" << status_train(train)
    end
    result_string
  end

  def status_train(train)
    train_wagons, train_capacity_totals = status_train_wagons(train)
    "  #{train.number_get}" \
      " '#{train.route_get&.title}'" \
      " #{train.type_get.to_s.gsub('cargo', 'ГРУЗОВОЙ').gsub('passenger', 'ПАССАЖИРСКИЙ')}" \
      ", на станции: '#{train.curr_station_get&.title}'" \
      ", вагоны: #{train.wagons_count}шт." \
      " доступно: #{train_capacity_totals[1]} занято #{train_capacity_totals[0]}" \
      " #{train.type_get.to_s.gsub('cargo', 'тонн').gsub('passenger', 'мест')}" \
      "\r\n         (выгоны: #{train_wagons.join('; ')})"
  end

  def status_train_wagons(train)
    train_capacity_totals = [0, 0]
    train_wagons = []
    train.wagons_map do |wagon|
      train_capacity_totals[0] += wagon.capacity_used
      train_capacity_totals[1] += wagon.capacity_free
      train_wagons << "№#{train_wagons.size + 1}" \
                      " #{wagon.type_get.to_s.gsub('cargo', 'ГРУЗ').gsub('passenger', 'ПАС')}" \
                      " св.:#{wagon.capacity_free}" \
                      " з.:#{wagon.capacity_used}"
    end
    [train_wagons, train_capacity_totals]
  end

  def status_routes
    result_string = "\n" << " \033[1mМаршруты\033[0m"
    @routes.each do |route|
      result_string << "\n" << "  #{route.title}   (#{route.stations_get.map(&:title).join(', ')})"
    end
    result_string
  end

  def status_stations
    result_string = "\n" << " \033[1mСтанции\033[0m"
    @stations.each do |station|
      station_trains = []
      station.trains_get.map do |train|
        station_trains << "#{train.number_get}" \
                          " #{train.type_get.to_s.gsub('cargo', 'ГРУЗ').gsub('passenger', 'ПАС')}" \
                          " #{train.route_get&.title}" \
                          " вагонов:#{train.wagons_count}"
      end
      result_string << "\n" << "  #{station.title} поезда на станции: #{station_trains.join('; ')}"
    end
    result_string
  end

  def seed
    # @station_not_in_route = Station.new('Ильская')
    @stations = create_stations('Москва', 'Воронеж', 'Ростов на Дону', 'Краснодар', 'Горячий ключ')
    test_stations

    @routes = create_routes
    test_routes

    test_wagon

    @trains = seed_trains
    test_trains
  end

  def train_type_by_sign(sign)
    { 'П' => PassengerTrain, 'Г' => CargoTrain }.freeze[sign]
  end

  def wagon_type_by_sign(sign)
    { 'П' => PassengerWagon, 'Г' => CargoWagon }.freeze[sign]
  end

  def build_train(train_number)
    train_type_by_sign(train_number.chars.last)
      .new(train_number)
      .wagons_add(wagon_type_by_sign(train_number.chars.last), 5)
  end

  def correct_seed_train(new_train, train_idx)
    case train_idx
    when 0
      new_train.wagons_map { |w| w.capacity_take(10) }
      new_train.wagons_map(&:capacity_take_one)
      new_train.manufacturer = 'manufacturer_caption'
    when 1
      new_train.wagons_map { |w| w.capacity_take(10.0) }
    when 2
      new_train.route_set(routes.first)
    when 3
      new_train.route_set(routes.last)
      3.times { new_train.wagon_remove }
    when 4
      new_train.route_set(routes.first)
      2.times { new_train.wagon_remove }
    when 5
      5.times { new_train.wagon_remove }
    end
  end

  def seed_trains
    %w[01А-0П 02Б-0Г 03В-АГ 04Г-ЖП 05Д-4Г 06Е-АП].map.with_index do |train_number, train_idx|
      correct_seed_train(build_train(train_number), train_idx)
    end
  rescue StandardError => e
    puts e
    exit
  end

  def test_trains
    raise 'Ошибка проверки доработок Manufacturer' if @trains[0].manufacturer != 'manufacturer_caption'

    # TODO: EXTRACT METHOD
    begin
      [[3, 37], [2, 50.1]].each do |wrong_param|
        @trains[wrong_param[0]].wagons_map { |wagon| wagon.capacity_take(wrong_param[1]) }
      end
    rescue StandardError
      # do nothing
    end
    raise 'Ошибка проверки доработок Wagons (полезная нагрузка) проверка capacity_take' if
      wrong_train_wagons_capacities?

    # TODO: EXTRACT METHOD
    train = nil
    begin
      train = Train.new('987-ZA')
    rescue StandardError
      # do nothing
    end
    raise 'Поезд должен быть PassengerTrain или CargoTrain, не Train' if train

    # TODO: EXTRACT METHOD
    train = nil
    begin
      train = Train.new('01А-0П')
    rescue StandardError
      # do nothing
    end
    raise 'Ошибка доработок, нельзя создать поезд с повторяющимся номером' if train

    raise 'Ошибка проверки доработок Train' if wrong_trains_counts?

    raise 'Ошибка проверки доработок Station.trains_map' if
      @stations.first.trains_map { |t| "№#{t.number_get}" }.join(' ') != '№03В-АГ №05Д-4Г'

    raise 'Ошибка проверки доработок Train.wagons_map' if
      @stations.first.trains_get.first.wagons_map { |w| "Class#{w.class}" }.uniq.first != 'ClassCargoWagon'
  end

  def wrong_train_wagons_capacities?
    [[0, 25, 11], [1, 40, 10], [2, 50, 0], [3, 36, 0]].map do |check_param|
      @trains[check_param[0]].wagons_map(&:capacity_free).uniq.first != check_param[1] ||
        @trains[check_param[0]].wagons_map(&:capacity_used).uniq.first != check_param[2]
    end.any?
  end

  def wrong_trains_counts?
    Train.find(@trains[2]).number_get != @trains[2].number_get ||
      CargoTrain.instances != 3 ||
      PassengerTrain.instances != 3 ||
      @trains.count != 6
  end

  def create_wrong_station
    begin
      station = Station.new('М')
    rescue StandardError
      # do nothing
    end

    begin
      station = Station.new('М123456789' * 5)
    rescue StandardError
      # do nothing
    end

    station
  end

  def create_stations(*new_stations_titles)
    new_stations_titles.map { |station_title| Station.new(station_title) }
  end

  def test_stations
    raise 'Ошибка проверки доработок Station (instance_counter)' if stations_count_wrong?(@stations)

    return unless create_wrong_station

    raise 'Ошибка проверки доработок Station. Название Станции должно быть от 2-х до 32 буквы, цифры, пробел'
  end

  def stations_count_wrong?(stations)
    Station.instances != 5 || Station.all.count != 5 || stations.count != 5
  end

  def test_wagon
    begin
      wagon = Wagon.new
    rescue StandardError
      # do nothing
    end
    raise 'Ошибка проверки доработок Wagon. Можно создать только CargoWagon или PassengerWagon' if wagon
  end

  def create_routes
    [ # [[from, to], [intermediate, insert_index]]
      [[0, 4], [[1, 2, 3], 4]],
      [[2, 4], [3, 4]],
      [[1, 4], [3, 4]]
    ].map do |new_route_stations|
      Route
        .new(@stations[new_route_stations[0][0]], @stations[new_route_stations[0][1]])
        .stations_insert(@stations.values_at(*new_route_stations[1][0]), @stations[new_route_stations[1][1]])
    end
  end

  def test_routes
    @routes[0].station_remove(@stations[2])
    @routes[0].station_insert(@stations[2], @stations[3])
    raise 'Ошибка проверки доработок Route (instance_counter)' if Route.instances != 3 || @routes.count != 3
  rescue StandardError => e
    puts e
    exit
  end
end
