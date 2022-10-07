#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'


MENU = [
  {
    command: "Д", description: "Диспетчерская",
    object_show: "@railway" },
  {
    command: "С?", description: "Просмотреть список станций",
    list_titles: "@railway.stations"
  },
  {
    command: "С+", description: "Создать станцию, например: \033[1mSC Москва\033[0m",
    object_create: "Station",  object_create_params: { "title" => "" }, target_list: "@railway.stations"
  },
  {
    command: "СП", description: "Просмотреть список поездов на станции, например: \033[1mSТ Москва\033[0m или \033[1mSТ\033[0m для всех",
    source_list: "@railway.stations", source_list_filter: { "title" => "" }, object_list_method: { "trains_get" => "number_get"}
  },
  # { command: :П+,  description: "Создавать поезда", params: "", list: nil },
  # { command: :ПМ, description: "Назначать маршрут поезду", params: "", list: nil },
  # { command: :ПМВ, description: "Перемещать поезд по маршруту вперед и", params: "", list: nil },
  # { command: :ПМН, description: "Перемещать поезд по маршруту назад", params: "", list: nil },
  #
  # { command: :ПВ+, description: "Добавлять вагоны к поезду", params: "", list: nil },
  # { command: :ПВ+, description: "Отцеплять вагоны от поезда", params: "", list: nil },
  #
  # { command: :МC,  description: "Создавать маршруты и ", params: "", list: nil },
  # { command: :RSV, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :RSA, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :RSR, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil }
].freeze


MENU_HELP = MENU.map do |mi|
  "  \033[1m#{mi[:command].to_s}\033[0m\t#{mi[:description].to_s}"
  # + ( mi[:object_create_params] ? " (#{mi[:object_create_params].keys.join(", ").to_s})" : "" )
end

@railway = RailWay.new(seed: true)


puts "\e[H\e[2J"
command = ""
loop do
  puts
  puts
  puts "\033[0;47;30mКоманда\tОписание\033[0m"
  puts MENU_HELP
  command_exit = "В"
  puts "  \033[1m#{command_exit}\033[0m\tВыход"
  puts
  print "введите команду: "
  if command == ""
    input = gets.chomp
    command = input.partition(' ').first.strip.upcase
  end
  puts "\e[H\e[2J"

  break if command == command_exit

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }

  if menu_selected.nil?
    command = ""
    next
  end


  puts
  puts "\033[1;43;37m #{menu_selected[:description]}\033[0m\033[1;43;37m: \033[0m "


  if menu_selected[:object_show]
    # object_show: "@railway" }
    eval(menu_selected[:object_show]).show
    command = ""


  elsif menu_selected[:object_create]
    # object_create: "Station",  object_create_params: { "title" => "" }, target_list: "@railway.stations"
    eval_command = menu_selected[:target_list] ? "#{menu_selected[:target_list]} << " : ""
    eval_command += "#{menu_selected[:object_create]}.new"
    if menu_selected[:object_create_params]
      params_count = menu_selected[:object_create_params].keys.map(&:to_s).count
      params_mods = menu_selected[:object_create_params].values.map(&:to_s) # to_i, to_f ...
      input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
      constructor_params = input_params_values[..params_count].zip(params_mods).map { |i| "\""+i[0]+"\""+i[1] }.join(", ")
      eval_command += "(#{ constructor_params })"
    end
    eval(eval_command)
    command = "I"


  elsif menu_selected[:list_titles]
    # list_titles: "@railway.stations"
    eval(menu_selected[:list_titles]).each { |item| puts " #{item.title}" }
    command = ""
    # TODO возможно дублирует menu_selected[:source_list] без параметров, проработать
    # + ,source_list_method: :"title"
    # = source_list: "@railway.stations", source_list_filter: { "title" => "" }

  elsif menu_selected[:source_list]
    # source_list: "@railway.stations", source_list_filter: { "title" => "" }, object_list_method: { "trains_get" => "number_get"}

    # source_list
    eval_command = "#{menu_selected[:source_list]}"

    # source_list_filter
    input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
    input_params_values = ["Воронеж", "Москва"] # TODO remove after DEBUG
    # params_mods = menu_selected[:object_create_params].values.map(&:to_s) if menu_selected[:object_create_params] # TODO check .to_i .to_s для не String'ов
    source_list_filter_key = menu_selected[:source_list_filter].keys.map(&:to_s).first if menu_selected[:source_list_filter]
    if source_list_filter_key && (input_params_values.count > 0)
      eval_command += ".select {|source_list_item| #{input_params_values.to_s}.include?(source_list_item.#{source_list_filter_key})}"
    end
    source_list_result = eval(eval_command)

    puts
    source_list_result.each do |source_list_item|
      puts " \033[1;43;37m #{source_list_item.send(source_list_filter_key)} \033[0m"
      puts

      # TODO && source_list_filter && object_list_method
      #>>>
      # WIP TODO выводим     object_list_method: { "trains_get" => "number_get"}
      # eval_command =
    end
    #binding.pry

    command = ""
  else
    command = ""
  end

end
puts