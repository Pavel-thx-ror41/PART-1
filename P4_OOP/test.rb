require 'pry'

require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'


stations = []
stations << Station.new('Москва')         # 0
stations << Station.new('Воронеж')        # 1
stations << Station.new('Ростов на Дону') # 2
stations << Station.new('Краснодар')      # 3
stations << Station.new('Горячий ключ')   # 4

route = Route.new(stations.first, stations.last)


  route.station_insert(stations[1], stations.last)    # ok
  route.station_insert(stations[2], stations.last)    # ok
# route.station_insert(stations[3], stations.first)   # error before first
# route.station_insert(stations[2], stations.last)    # error copy
  route.station_insert(stations[3], stations.last)    # ok

  route.station_remove(stations[3])
  route.station_remove(stations[2])
  route.station_remove(stations[1])

  route.station_insert(stations[1], stations.last)    # ok
  route.station_insert(stations[2], stations.last)    # ok
  route.station_insert(stations[3], stations.last)    # ok

binding.pry # route.stations_get
exit


