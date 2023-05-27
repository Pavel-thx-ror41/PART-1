# frozen_string_literal: false

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_train'
require_relative 'cargo_wagon'
require_relative 'passenger_train'
require_relative 'passenger_wagon'
require_relative 'rail_way_test'

class RailWay
  attr_reader :stations, :routes, :trains

  # @station_not_in_route

  def initialize(do_seed: false)
    @stations = []
    @routes = []
    @trains = []

    return unless do_seed

    seed
    RailWay::Test.call(@stations, @routes, @trains)
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
    @routes = create_routes
    @trains = seed_trains
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

  def correct_seed_train(train, train_idx)
    case train_idx
    when 0
      train.wagons_map { |w| w.capacity_take(10) }
      train.wagons_map(&:capacity_take_one)
      train.manufacturer = 'manufacturer_caption_one'
      train.manufacturer = 'manufacturer_caption_two'
      train.manufacturer = 'manufacturer_caption_three'
    when 1
      train.wagons_map { |w| w.capacity_take(10.0) }
    when 2
      train.route_set(routes.first)
    when 3
      train.route_set(routes.last)
      3.times { train.wagon_remove }
    when 4
      train.route_set(routes.first)
      2.times { train.wagon_remove }
    when 5
      5.times { train.wagon_remove }
    end
    train
  end

  def seed_trains
    %w[01А-0П 02Б-0Г 03В-АГ 04Г-ЖП 05Д-4Г 06Е-АП].map.with_index do |train_number, train_idx|
      correct_seed_train(build_train(train_number), train_idx)
    end
  rescue StandardError => e
    puts e
    exit
  end

  def create_stations(*new_stations_titles)
    new_stations_titles.map { |station_title| Station.new(station_title) }
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
end
