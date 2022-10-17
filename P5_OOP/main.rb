#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'

CLS = "\e[H\e[2J"
COMMAND_INFO = "Д"
COMMAND_EXIT = "Х"

MENU = [
  {
    command: COMMAND_INFO,
    caption: "Диспетчерская",
    description: "Диспетчерская (посмотреть всю дорогу)",
    object_show: "@railway"
  },

  {
    command: "С",
    caption: "Станции",
    description: "Станции, просмотреть список",
    source_list: "@railway.stations",
    source_list_filter: { "title" => "" }
  },
  {
    command: "С+",
    caption: "Добавление Станции",
    description: "Станцию создать, например: \033[1mС+ Москва\033[22m",
    object_create: "Station",
    object_create_params: { "title" => "" },
    target_list: "@railway.stations"
  },
  {
    command: "СП",
    caption: "Станции и Поезда на них",
    description: "Станция, поезда на ней (список поездов на станции(ях), например: \033[1mСП Москва, Воронеж\033[22m или \033[1mСП\033[22m для всех)",
    source_list: "@railway.stations",
    source_list_filter: { "title" => "" },
    object_sublist_and_title_methods: { "trains_get" => "number_get"}
  },

  {
    command: "П",
    caption: "Поезда",
    description: "Поезда, посмотреть список",
    source_list: "@railway.trains",
    source_list_filter: { "number_get" => "" }
  },
  {
    command: "П+",
    caption: "Добавление Поезда",
    description: "Поезд создать, например: \033[1mП+ 007,ПАСС\033[22m или \033[1mП+ 007,ГРУЗ\033[22m",
    object_create: "Train",
    object_create_params: { "number" => "", "type" => ".strip.chars.first.upcase.gsub(\"Г\", \"cargo\").gsub(\"П\", \"passenger\").to_sym" },
    target_list: "@railway.trains"
  },
  # { command: :ПМ, description: "Назначать маршрут поезду", params: "", list: nil },
  # { command: :ПМВ, description: "Перемещать поезд по маршруту вперед и", params: "", list: nil },
  # { command: :ПМН, description: "Перемещать поезд по маршруту назад", params: "", list: nil },
  #
  # { command: :ПВ+, description: "Добавлять вагоны к поезду", params: "", list: nil },
  # { command: :ПВ+, description: "Отцеплять вагоны от поезда", params: "", list: nil },

  {
    command: "М+",
    description: "Маршрут создать, например: \033[1mМ+ Воронеж, Краснодар\033[22m",
    object_create: "Route",
    object_create_params_lookup: { "from" => {"@railway.stations" => "title"}, "to" => {"@railway.stations" => "title"} },
    target_list: "@railway.routes"
  }
  # { command: :МС,  description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :МС+, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :МС-, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil }

].freeze


MENU_HELP = MENU.map do |mi|
  " \033[1m#{mi[:command].to_s}\033[22m\t  #{mi[:description].to_s}"
end


def execute_command(menu_selected: nil, input: nil)
  puts
  puts "\033[100m \033[1m#{menu_selected[:caption]}\033[22m \033[0m"

  if menu_selected[:object_show]
    # Вызов .show для объекта
    # object_show: "@railway"
    #
    eval(menu_selected[:object_show]).show
    command = ""


  elsif menu_selected[:object_create]
    # Создать экземпляр класса с именем в :object_create, с параметрами из :object_create_params, в списке :target_list
    # object_create: "Station",  object_create_params: { "title" => "to_s" }, target_list: "@railway.stations"

    next_command = COMMAND_INFO
    eval_command = menu_selected[:target_list] ? "#{menu_selected[:target_list]} << " : ""
    eval_command += "#{menu_selected[:object_create]}.new"

    if menu_selected[:object_create_params]
      params_count = menu_selected[:object_create_params].keys.map(&:to_s).count
      params_mods = menu_selected[:object_create_params].values.map(&:to_s) # to_i, to_f ...
      input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
      constructor_params = input_params_values[..params_count].zip(params_mods).map { |i| "\""+i[0]+"\""+i[1] }.join(", ")
      eval_command += "(#{ constructor_params })"
      if params_count != input_params_values.count
        puts "Не верное количество параметров, необходимо #{params_count} а именно: #{menu_selected[:object_create_params].keys.map(&:to_s).join(", ")}"
        eval_command = ""
        next_command = ""
      end
    elsif menu_selected[:object_create_params_lookup]
      # object_create_params_lookup: { "@railway.stations" => "title", "@railway.stations" => "title" },
      binding.pry # TODO CREATE WITH LOOKUP BY STRING




      eval_command = ""
      next_command = ""
    end

    eval(eval_command)
    command = next_command


  elsif menu_selected[:source_list]
    # source_list: "@railway.stations", source_list_filter: { "title" => "" }, object_sublist_and_title_methods: { "trains_get" => "number_get"}
    # source_list: "@railway.trains", source_list_filter: { "number_get" => "" }

    eval_command = "#{menu_selected[:source_list]}"

    input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
    source_list_filter_method = menu_selected[:source_list_filter].keys.map(&:to_s).first if menu_selected[:source_list_filter]
    if source_list_filter_method && (input_params_values.count > 0)
      puts " только для: #{input_params_values.join(", ")}"
      eval_command += ".select {|source_list_item| #{input_params_values.to_s}.include?(source_list_item.#{source_list_filter_method})}"
    end
    source_list_result = eval(eval_command)

    puts
    source_list_result.each do |source_list_item|
      puts "  \033[1m#{source_list_item.send(source_list_filter_method)}\033[22m"

      #source_list: "@railway.trains", source_list_filter: { "number_get" => "" } #, object_sublist_and_title_methods: { "route_get" => "title"}
      if menu_selected[:object_sublist_and_title_methods]
        eval_command = "source_list_item.#{menu_selected[:object_sublist_and_title_methods].keys.first}.map {|item_list| item_list.#{menu_selected[:object_sublist_and_title_methods].values.first} }"
        sub_list = eval(eval_command)
        puts "   " + sub_list.join(", ") if sub_list.count > 0
        puts
      end
    end

    command = ""
  else
    command = ""
  end
  command
end



@railway = RailWay.new(seed: true)

puts CLS
command = COMMAND_INFO

loop do
  puts
  puts
  puts "\033[30;47m Команда  Описание \033[39;49m"
  puts MENU_HELP
  puts "\033[1m #{COMMAND_EXIT}\033[22m\t  Выход"
  puts
  print "введите команду: "

  if command == ""
    input = gets.chomp
    command = input.partition(' ').first.strip.upcase
  end
  puts CLS

  break if command == COMMAND_EXIT

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }

  if menu_selected.nil?
    command = ""
    next
  end

  command = execute_command(menu_selected: menu_selected, input: input)
end

puts
