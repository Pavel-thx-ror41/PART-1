#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'


MENU = [
  {
    command: "I",
    description: "Диспетчерская",
    info: "@railway" },
  {
    command: "SV",
    description: "Просмотреть список станций",
    list: "@railway.stations"
  },
  {
    command: "SC",
    description: "Создать станцию, например: \033[1mSC Москва\033[0m",
    object: "Station",
    params: { "title" => ".to_s" },
    target: "@railway.stations"
  },
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


MENU_HELP = MENU.map do |mi|
  "  \033[1m#{mi[:command].to_s}\033[0m\t#{mi[:description].to_s}"
  # + ( mi[:params] ? " (#{mi[:params].keys.join(", ").to_s})" : "" )
end

@railway = RailWay.new(seed: true)


puts "\e[H\e[2J"
loop do
  puts
  puts "\033[0;47;30mКоманда\tОписание\033[0m"
  puts MENU_HELP
  puts "  \033[1mQ\033[0m\tВыход"
  puts
  print "введите команду: "
  input = gets.chomp
  puts "\e[H\e[2J"


  command = input.partition(' ').first.upcase
  break if command == "Q"

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }
  next if menu_selected.nil?


  puts
  puts "\033[1;43;37m     #{menu_selected[:description]}:     \033[0m"
  if menu_selected[:info]
    eval(menu_selected[:info]).show
  elsif menu_selected[:list]
    # @railway.stations  @railway.instance_variable_get('@stations')
    eval(menu_selected[:list]).each { |item| puts " #{item.title}" }
  elsif menu_selected[:object]
    params_keys = menu_selected[:params].keys.map(&:to_s) if menu_selected[:params]
    params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
    #params_eval = Hash[params_keys.zip(params_values)]

    eval_command = ""
    eval_command += "#{menu_selected[:target]} << " if menu_selected[:target]
    eval_command += "#{menu_selected[:object]}.new"
    puts eval_command

    binding.pry
    # params: { "title" => "String" },
    # eval(" #{menu_selected[:params]}  ")
    #eval(menu_selected[:list]).each { |item| puts " #{item.title}" } # @railway.stations  @railway.instance_variable_get('@stations')
  end
  puts


end
