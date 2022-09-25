require 'pry'
require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'



puts;puts
puts "--- Станции -----------------------------------------------"
stations = []
stations << Station.new('Москва')         # 0
stations << Station.new('Воронеж')        # 1
stations << Station.new('Ростов на Дону') # 2
stations << Station.new('Краснодар')      # 3
stations << Station.new('Горячий ключ')   # 4
station_not_in_route = Station.new('Ильская')

stations.each { |s| puts " #{s.instance_variable_get('@title')}" }



puts;puts
puts "--- Маршрут -----------------------------------------------"
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

puts " route.station_get_prev/next_from (route.stations_get.each)"
route.stations_get.each do |s|
  puts "  '#{route.station_get_prev_from(s).instance_variable_get('@title')}'      >     "\
  "'#{s.instance_variable_get('@title')}'     >     "\
  "'#{route.station_get_next_from(s).instance_variable_get('@title')}'"
end

puts
puts " route.station_get_prev/next_from (station_not_in_route)"
puts "  '#{route.station_get_prev_from(station_not_in_route).instance_variable_get('@title')}'   >   "\
  "'#{station_not_in_route.instance_variable_get('@title')}'   >   "\
  "'#{route.station_get_next_from(station_not_in_route).instance_variable_get('@title')}'"



puts;puts
puts "--- Поезд -------------------------------------------------"
train = Train.new("001", :cargo)

puts
puts " speed(10) +3 вагона"
train.speed_set(10)
train.wagon_add
train.wagon_add
train.wagon_add
puts "  wagons_count #{train.wagons_count}" # 0

puts
puts " speed(0) +4, -1 вагон"
train.speed_set(0)
train.wagon_add
train.wagon_add
train.wagon_add
train.wagon_add
train.wagon_remove
puts "  wagons_count #{train.wagons_count}" # 3

puts
puts " route_set(route)"
train.route_set(route)
puts "  train.route.stations.titles: #{train.instance_variable_get('@route').stations_get.map{|station| station.instance_variable_get('@title') }}"
puts "  train.current_station.title: #{train.instance_variable_get('@current_station').instance_variable_get('@title')}"

puts
puts " route_get_curr_station: #{train.route_get_curr_station.instance_variable_get('@title')}"
puts "  get prev: #{train.route_get_prev_station.instance_variable_get('@title')}"
puts " move next 3x, move prev 1x"
train.route_move_next_station
puts "  move next #{train.route_get_curr_station.instance_variable_get('@title')}"
train.route_move_next_station
puts "  move next #{train.route_get_curr_station.instance_variable_get('@title')}"
train.route_move_next_station
puts "  move next #{train.route_get_curr_station.instance_variable_get('@title')}"
train.route_move_prev_station
puts "  move prev #{train.route_get_curr_station.instance_variable_get('@title')}"

puts
puts " route_get_curr_station: #{train.route_get_curr_station.instance_variable_get('@title')}"
puts "  get prev: #{train.route_get_prev_station.instance_variable_get('@title')}"
puts "  get next: #{train.route_get_next_station.instance_variable_get('@title')}"

puts
train.route_move_next_station
puts "  move next #{train.route_get_curr_station.instance_variable_get('@title')}"
train.route_move_next_station
puts "  move next #{train.route_get_curr_station.instance_variable_get('@title')}"
puts "  get next: #{train.route_get_next_station.instance_variable_get('@title')}"





puts;puts
# binding.pry



