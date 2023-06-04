# frozen_string_literal: false

require_relative 'manufacturer'
require_relative 'validations'
require_relative 'instance_counter'

class Train
  include Manufacturer
  include Validations
  validate :number, :format, /^(\d|[A-ZА-Я]|Ё){3}-?(\d|[A-ZА-Я]|Ё){2}$/i,
           message: 'Номер должен быть в формате: ' \
                    'три буквы или цифры, необязательный дефис, две буквы или цифры после дефиса'
  validate :self, message: 'Можно создать только PassengerTrain или CargoTrain, номер без повторов' do |instance|
    (instance.instance_of?(CargoTrain) || instance.instance_of?(PassengerTrain)) &&
      !Train.others_with_same_number?(instance)
  end
  # объявлять до InstanceCounter, т.к. в InstanceCounter проверка NotImplementedError !
  include InstanceCounter

  # rubocop:disable Style/ClassVars
  @@trains = []
  # rubocop:enable Style/ClassVars

  def self.find(train)
    @@trains.detect { |t| t == train }
  end

  def initialize(number)
    @number = number
    @speed = 0
    @wagons = []
    @route = nil
    @current_station = nil

    validate!
    @@trains << self
  end

  def self.others_with_same_number?(train)
    @@trains.find_all { |t| (t.number_get == train.number_get) && !t.equal?(train) }.any?
  end

  def number_get
    @number
  end

  def type_get
    self.class.to_s.gsub('Train', '').downcase.to_sym
  end

  def speed_set(speed)
    @speed = speed.to_i
  end

  def speed_get
    @speed
  end

  def speed_stop
    @speed = 0
  end

  def wagons_count
    @wagons.count
  end

  def wagon_remove
    raise 'Невозможно отцепить вагон на ходу' unless stopped?
    raise 'Нет вагонов, нечего отцеплять' unless @wagons.pop
  end

  def wagon_add(wagon)
    raise 'Ошибка данных, тип Вагона не соответствует типу Поезда' unless stopped? && wagon_is_same_kind?(wagon)

    @wagons << wagon
  end

  def wagons_add(type, count)
    count.times do
      wagon_add(type.new)
    end

    self
  end

  def route_set(route)
    unless route.is_a?(Route) && route.stations_get.first.is_a?(Station)
      raise "Ошибка данных, тип параметра route: #{route.class}, должен быть Route, с первым элементом Station"
    end

    @route = route
    @current_station = @route.stations_get.first
    @current_station.train_arrive(self)

    self
  end

  def route_get
    @route
  end

  def route_move_next_station
    raise 'Поезд в депо .' unless @current_station

    next_station = @route&.station_get_next_from(@current_station)
    raise 'Нет следующей станции.' unless next_station

    @current_station.train_depart(self)
    @current_station = next_station
    @current_station.train_arrive(self)
  end

  def route_move_prev_station
    prev_station = @route.station_get_prev_from(@current_station)
    raise 'Ошибка. Нет предыдущей станции.' unless prev_station

    @current_station.train_depart(self)
    @current_station = prev_station
    @current_station.train_arrive(self)
  end

  def curr_station_get
    @current_station
  end

  def wagons_get
    @wagons
  end

  def wagons_map(&block)
    @wagons.map { |wagon| block.call(wagon) } if block_given?
  end

  protected

  # будет вызываться у наследников
  def wagon_is_same_kind?(wagon)
    wagon.class.to_s.gsub('Wagon', '') == self.class.to_s.gsub('Train', '')
  end

  # будет вызываться у наследников
  def stopped?
    @speed.zero?
  end
end
