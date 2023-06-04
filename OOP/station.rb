# frozen_string_literal: false

require_relative 'train'
require_relative 'validations'
require_relative 'instance_counter'

class Station
  include Validations
  validate :title, :present
  validate :title, :type, String
  validate :title, :format, /^(\d|[A-ZА-Я]|Ё| ){2,32}$/i,
           message: 'Ошибка. Допустимый формат: от 2-х до 32 буквы, цифры, пробел'
  # объявлять до InstanceCounter, т.к. в InstanceCounter проверка NotImplementedError !

  include InstanceCounter

  # rubocop:disable Style/ClassVars
  @@stations = []
  # rubocop:enable Style/ClassVars

  def self.all
    @@stations
  end

  def initialize(title)
    @title = title
    @trains = []

    validate!
    @@stations << self
  end

  attr_reader :title

  def train_arrive(train)
    if (train.is_a?(PassengerTrain) || train.is_a?(CargoTrain)) && !@trains.index(train)
      @trains << train
    else
      raise 'Ошибка данных. ' \
            "Неправильный тип параметров: #{train.class}, требуется: PassengerTrain или CargoTrain, " \
            'или эта станция не следующая по маршруту, уже в списке поездов на станции'
    end
  end

  def trains_get
    @trains
  end

  def trains_get_by_type(type)
    @trains.select { |train| train.type_get == type }
  end

  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def train_depart(train)
    if (train.is_a?(PassengerTrain) ||
       train.is_a?(CargoTrain)) &&
       @trains.index(train) &&
       train.curr_station_get == self

      @trains.delete(train)
    else
      raise 'Ошибка данных. ' \
            "Неправильный тип параметров: #{train.class}, требуется: PassengerTrain или CargoTrain, " \
            'или эта станция не текущая для поезда, или не в списке поездов на станции'
    end
  end

  def trains_map(&block)
    @trains.map { |train| block.call(train) } if block_given?
  end
end
