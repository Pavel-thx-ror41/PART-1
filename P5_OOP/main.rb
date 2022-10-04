#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'

@railway = RailWay.new(seed: true)

MENU = [
  { command: "I", description: "Диспетчерская", info: "@railway" },

  { command: "SV", description: "Просмотреть список станций", list: "@railway.stations" },
  { command: "SC", description: "Создать станцию", object: "Station", params: [{ title: :String }], target: "@railway.stations" },
  # { command: :ST, description: "список поездов на станции", params: "", list: nil },
  #
  # { command: :TC,  description: "Создавать поезда", params: "", list: nil },
  # { command: :TRS, description: "Назначать маршрут поезду", params: "", list: nil },
  # { command: :TRF, description: "Перемещать поезд по маршруту вперед и", params: "", list: nil },
  # { command: :TRB, description: "Перемещать поезд по маршруту назад", params: "", list: nil },
  #
  # { command: :TWA, description: "Добавлять вагоны к поезду", params: "", list: nil },
  # { command: :TWR, description: "Отцеплять вагоны от поезда", params: "", list: nil },
  #
  # { command: :RC,  description: "Создавать маршруты и ", params: "", list: nil },
  # { command: :RSV, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :RSA, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :RSR, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil }
].freeze

MENU_HELP = MENU.map { |mi| "  \033[1m#{mi[:command].to_s}\033[0m\t#{mi[:description].to_s}" }.freeze
puts "\e[H\e[2J"


loop do

  puts
  puts "\033[1;43;37mКоманда\tОписание\033[0m"
  puts MENU_HELP
  puts "  \033[1mQ\033[0m  \tВыход"
  puts
  print "введите команду: "
  input = gets.chomp

  puts "\e[H\e[2J"
  # input = "SV"
  # input = "SC, Краковка"
  command = input.partition(' ').first.upcase
  params = input.partition(' ').last

  break if command == "Q"

  user_menu_choice = MENU.find { |mi| mi[:command] == command.to_s }
  next if not user_menu_choice

  puts
  puts "\033[1;43;37m     #{user_menu_choice[:description]}:     \033[0m"
  if user_menu_choice[:info]
    eval(user_menu_choice[:info]).show
  elsif user_menu_choice[:list]
    eval(user_menu_choice[:list]).each { |item| puts " #{item.title}" } # @railway.stations  @railway.instance_variable_get('@stations')
  end
  puts


end
