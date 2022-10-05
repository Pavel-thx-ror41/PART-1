require_relative 'station.rb'
require_relative 'route.rb'
# require_relative 'wagon.rb'
# require_relative 'train.rb'
# require_relative 'cargo_train.rb'
# require_relative 'passenger_train.rb'

class RailWay
  attr_reader :stations
  # @station_not_in_route
  attr_reader :routes

  def initialize(seed: false)
    @stations = []
    @routes = []
    self.seed if seed
  end

  def show
    puts
    puts " \033[1;43;37m Станции            \033[0m"
    self.stations.each { |station| puts "  #{station.title}" }

    puts
    puts " \033[1;43;37m Маршруты           \033[0m"
    self.routes.each { |route| puts "  #{route.title}" }

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

    route.station_insert(stations[1], stations.last)             # ok
    route.station_insert(stations[2], stations.last)             # ok
    # route.station_insert(stations[2], stations.last)           # error copy
    # route.station_insert(station_not_in_route, stations.first) # error before first
    route.station_insert(stations[3], stations.last)             # ok
    route.station_remove(stations[3])
    route.station_remove(stations[2])
    route.station_remove(stations[1])

    route.station_insert(stations[1], stations.last)    # ok
    route.station_insert(stations[2], stations.last)    # ok
    route.station_insert(stations[3], stations.last)    # ok
    self.routes << route
  end

end
