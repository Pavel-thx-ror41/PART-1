# frozen_string_literal: false

class RailWay
  class Test
    def self.call(stations, routes, trains)
      test_stations(stations)
      test_routes(routes, stations)
      test_wagon
      test_trains(trains, stations)
    end

    def self.test_trains(trains, stations)
      raise 'Ошибка проверки доработок Manufacturer' unless test_manufacturer(trains)

      try_take_wrong_wagons_capacities(trains)
      raise 'Ошибка проверки доработок Wagons (полезная нагрузка) проверка capacity_take' if
        wrong_train_wagons_capacities?(trains)

      # train = try_create_train_with_wrong_number
      if try_create_train_with_wrong_number
        raise 'Номер поезд должен быть: три буквы или цифры, необязательный дефис, две буквы или цифры после дефиса'
      end

      raise 'Поезд должен быть PassengerTrain или CargoTrain, не Train' if try_create_train_with_wrong_type

      # train = try_create_train_with_existed_number
      raise 'Ошибка доработок, нельзя создать поезд с повторяющимся номером' if try_create_train_with_existed_number

      raise 'Ошибка проверки доработок Train' if wrong_trains_counts?(trains)

      raise 'Ошибка проверки доработок Station.trains_map' if
        stations.first.trains_map { |t| "№#{t.number_get}" }.join(' ') != '№03В-АГ №05Д-4Г'

      raise 'Ошибка проверки доработок Train.wagons_map' if
        stations.first.trains_get.first.wagons_map { |w| "Class#{w.class}" }.uniq.first != 'ClassCargoWagon'
    end

    def self.wrong_trains_counts?(trains)
      Train.find(trains[2]).number_get != trains[2].number_get ||
        CargoTrain.instances != 3 ||
        PassengerTrain.instances != 3 ||
        trains.count != 6
    end

    def self.try_create_train_with_existed_number
      train = nil
      begin
        train = Train.new('01А-0П')
      rescue StandardError
        # do nothing
      end
      train
    end

    def self.try_create_train_with_wrong_type
      train = nil
      begin
        train = Train.new('987-ZA')
      rescue StandardError
        # do nothing
      end
      train
    end

    def self.try_create_train_with_wrong_number
      train = nil
      begin
        train = CargoTrain.new('987&^%&^%-ZA_JKFJ')
      rescue StandardError
        # do nothing
      end
      train
    end

    def self.wrong_train_wagons_capacities?(trains)
      [[0, 25, 11], [1, 40, 10], [2, 50, 0], [3, 36, 0]].map do |check_param|
        trains[check_param[0]].wagons_map(&:capacity_free).uniq.first != check_param[1] ||
          trains[check_param[0]].wagons_map(&:capacity_used).uniq.first != check_param[2]
      end.any?
    end

    def self.try_take_wrong_wagons_capacities(trains)
      [[3, 37], [2, 50.1]].each do |wrong_param|
        trains[wrong_param[0]].wagons_map { |wagon| wagon.capacity_take(wrong_param[1]) }
      end
    rescue StandardError
      # do nothing
    end

    def self.test_wagon
      begin
        wagon = Wagon.new
      rescue StandardError
        # do nothing
      end
      raise 'Ошибка проверки доработок Wagon. Можно создать только CargoWagon или PassengerWagon' if wagon
    end

    def self.test_routes(routes, stations)
      routes[0].station_remove(stations[2])
      routes[0].station_insert(stations[2], stations[3])
      raise 'Ошибка проверки доработок Route (instance_counter)' if Route.instances != 3 || routes.count != 3
    rescue StandardError => e
      puts e
      exit
    end

    def self.test_stations(stations)
      raise 'Ошибка проверки доработок Station (instance_counter)' if stations_count_wrong?(stations)

      return unless create_wrong_station

      raise 'Ошибка проверки доработок Station. Название Станции должно быть от 2-х до 32 буквы, цифры, пробел'
    end

    def self.stations_count_wrong?(stations)
      Station.instances != 5 || Station.all.count != 5 || stations.count != 5
    end

    def self.create_wrong_station
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

    def self.test_manufacturer(trains)
      trains[0].manufacturer == 'manufacturer_caption_three' &&
        trains[0].manufacturer_history == %w[
          manufacturer_caption_one manufacturer_caption_two manufacturer_caption_three
        ] &&
        trains[0].origin_country == 'Россия' &&
        trains[0].phoneprefix == 7 &&
        !can_set_wrong_strong_manufacturer_attr(trains)
    end

    def self.can_set_wrong_strong_manufacturer_attr(trains)
      trains[0].phoneprefix = 'String'
      true
    rescue StandardError
      false
    end
  end
end
