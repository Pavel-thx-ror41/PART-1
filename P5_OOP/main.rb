#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'


MENU = [
  {
    command: "I", description: "Диспетчерская",
    object_show: "@railway" },
  {
    command: "SL", description: "Просмотреть список станций",
    list_titles: "@railway.stations"
  },
  {
    command: "SC", description: "Создать станцию, например: \033[1mSC Москва\033[0m",
    object_create: "Station",  params: { "title" => "" }, target_list: "@railway.stations"
  },
  {
    command: "ST", description: "список поездов на станции",
    source_list: "@railway.stations", source_list_filter: { "title" => "" }, object_list_method: { "trains_get" => "number_get"}
  },
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
command = ""
loop do
  puts
  puts "\033[0;47;30mКоманда\tОписание\033[0m"
  puts MENU_HELP
  puts "  \033[1mQ\033[0m\tВыход"
  puts
  print "введите команду: "
  if command == ""
    input = gets.chomp
    command = input.partition(' ').first.upcase
  end
  puts "\e[H\e[2J"

  break if command == "Q"

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }

  if menu_selected.nil?
    command = ""
    next
  end


  puts
  puts "\033[1;43;37m     #{menu_selected[:description]}:     \033[0m"

  if menu_selected[:object_show]
    eval(menu_selected[:object_show]).show
    command = ""

  elsif menu_selected[:list_titles]
    eval(menu_selected[:list_titles]).each { |item| puts " #{item.title}" }
    command = ""

  elsif menu_selected[:object_create]
    # object_create: "Station",  params: { "title" => "" }, target_list: "@railway.stations"
    params_keys = menu_selected[:params].keys.map(&:to_s) if menu_selected[:params]
    params_count = params_keys.count
    params_mods = menu_selected[:params].values.map(&:to_s) if menu_selected[:params]
    params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)

    eval_command = ""
    eval_command += "#{menu_selected[:target_list]} << " if menu_selected[:target_list]
    eval_command += "#{menu_selected[:object_create]}.new"
    eval_command += "(#{ params_values[..params_count].zip(params_mods).map { |i| "\""+i[0]+"\""+i[1] }.join(", ") })" if params_keys

    eval(eval_command)
    command = "I"

  # elsif menu_selected[:object_create]
  #   # command: "ST", description: "список поездов на станции",
  #   # source_list: "@railway.stations", source_list_filter: { "title" => "" }, object_list_method: { "trains_get" => "number_get"}
  #
  #   # object_create: "Station",  params: { "title" => "" }, target_list: "@railway.stations"
  #   params_keys = menu_selected[:params].keys.map(&:to_s) if menu_selected[:params]
  #   params_count = params_keys.count
  #   params_mods = menu_selected[:params].values.map(&:to_s) if menu_selected[:params]
  #   params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
  #
  #   eval_command = ""
  #   eval_command += "#{menu_selected[:target_list]} << " if menu_selected[:target_list]
  #   eval_command += "#{menu_selected[:object_create]}.new"
  #   eval_command += "(#{ params_values[..params_count].zip(params_mods).map { |i| "\""+i[0]+"\""+i[1] }.join(", ") })" if params_keys
  #
  #   eval(eval_command)
  #   command = "I"

  else
    command = ""
  end

end
puts