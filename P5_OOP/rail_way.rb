require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
# require_relative 'wagon.rb'
# require_relative 'cargo_train.rb'
# require_relative 'passenger_train.rb'

class RailWay
  attr_reader :stations
  # @station_not_in_route
  attr_reader :routes
  attr_reader :trains

  def initialize(seed: false)
    @stations = []
    @routes = []
    @trains = []
    self.seed if seed
  end

  def show
    puts
    puts " \033[1mСтанции\033[0m"
    self.stations.each do |station|
      puts "  #{station.title}" +
           "   (поезда на станции: #{station.trains_get.map(&:number_get).join(", ")})"

    end

    puts
    puts " \033[1mМаршруты\033[0m"
    self.routes.each { |route| puts "  #{route.title}   (#{route.stations_get.map(&:title).join(", ")})" }



    puts
    puts " \033[1mПоезда\033[0m"
    self.trains.each do |train|
      puts "  #{train.number_get} #{train.route_get.title}" +
             "   (#{train.type_get}, #{train.wagons_count} вагонов, на станции #{train.curr_station_get.title})"
    end

    #return nil
  end

  private

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
    # route.station_insert(stations[2], stations.last)           # error copy
    # route.station_insert(station_not_in_route, stations.first) # error before first
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


    train = Train.new("001", :cargo)
    train.wagon_add
    train.wagon_add
    train.wagon_add
    train.wagon_add
    train.wagon_add
    self.trains << train

    train.route_set(routes.first)
    train.curr_station_get.train_arrive(train)


    train = Train.new("002", :cargo)
    train.wagon_add
    train.wagon_add
    train.wagon_add
    self.trains << train

    train.route_set(routes.last)
    train.curr_station_get.train_arrive(train)
  end

end
