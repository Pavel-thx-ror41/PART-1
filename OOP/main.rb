#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'

CLS = "\e[H\e[2J"
COMMAND_INFO = "Д"
COMMAND_CREATE_INPUT_ERROR = "ОШИБКА_ВВОДА_ПРИ_СОЗДАНИИ"
COMMAND_EXIT = "Х"

MENU = [
  {
    command: COMMAND_INFO,
    caption: "Диспетчерская",
    description: "Диспетчерская (посмотреть всю дорогу)",
    call_one_of_list: "@railway",
    call_one_of_list_method: "status"
  },

  { caption: " " },

  {
    command: "С",
    caption: "Станции",
    description: "Станции, просмотреть список",
    show_list_source: "@railway.stations",
    show_list_source_filter: { "title" => "" }
  },
  {
    command: "С+",
    caption: "Добавление Станции",
    description: "Станцию создать, например: \033[1mС+ Москва\033[22m",
    object_create: "Station",
    object_create_params: { "title" => ".squeeze(' ').strip" },
    target_list: "@railway.stations"
  },
  {
    command: "СП",
    caption: "Станции и Поезда на них",
    description: "Станция, поезда на ней (список поездов на станции(ях), например: \033[1mСП Москва, Воронеж\033[22m или \033[1mСП\033[22m для всех)",
    show_list_source: "@railway.stations",
    show_list_source_filter: { "title" => "" },
    object_sublist_and_title_methods: { "trains_get" => "number_get"}
  },

  { caption: " " },

  {
    command: "П",
    caption: "Поезда",
    description: "Поезда, посмотреть список",
    show_list_source: "@railway.trains",
    show_list_source_filter: { "number_get" => ".strip" }
  },
  {
    command: "П+П",
    caption: "Добавление ПассажирскогоПоезда",
    description: "Поезд создать (Пассажирский), например: \033[1mП+П 007\033[22m",
    object_create: "PassengerTrain",
    object_create_params: { "number" => ".squeeze(' ').strip" },
    target_list: "@railway.trains"
  },
  {
    command: "П+Г",
    caption: "Добавление ГрузовогоПоезда",
    description: "Поезд создать (Грузовой), например: \033[1mП+Г 009\033[22m",
    object_create: "CargoTrain",
    object_create_params: { "number" => ".squeeze(' ').strip" },
    target_list: "@railway.trains"
  },
  {
    command: "П<М",
    caption: "Назначить Поезду Маршрут",
    description: "Поезду назначить Маршрут, например: \033[1mП<М 004, Москва - Горячий ключ\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_set",
    call_one_of_list_method_params: [ { "@railway.routes" => { "title" => "[1]" } } ]
  },
  {
    command: "ПМВ",
    caption: "Поезд по Маршруту вперёд",
    description: "Поезд по Маршруту вперёд, например: \033[1mПМВ 003\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_move_next_station",
  },
  {
    command: "ПМН",
    caption: "Поезд по Маршруту назад",
    description: "Поезд по Маршруту назад, например: \033[1mПМН 003\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_move_prev_station",
  },
  {
    command: "ПВ+П",
    caption: "Поезд Вагон добавить пассажирский",
    description: "Поезд Вагон пассажирский добавить, например: \033[1mПВ+П 004\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_add(PassengerWagon.new)",
  },
  {
    command: "ПВ+Г",
    caption: "Поезд Вагон добавить грузовой",
    description: "Поезд Вагон грузовой добавить, например: \033[1mПВ+Г 003\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_add(CargoWagon.new)",
  },
  {
    command: "ПВ-",
    caption: "Поезд Вагон отцепить",
    description: "Поезд Вагон отцепить, например: \033[1mПВ- 003\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_remove",
  },

  { caption: " " },

  {
    command: "М",
    caption: "Маршруты",
    description: "Маршруты, посмотреть список",
    show_list_source: "@railway.routes",
    show_list_source_filter: { "title" => "" }
  },
  {
    command: "М+",
    description: "Маршрут создать, например: \033[1mМ+ Воронеж, Краснодар\033[22m",
    object_create: "Route",
    object_create_params_lookup: { "from" => {"@railway.stations" => "title"}, "to" => {"@railway.stations" => "title"} },
    target_list: "@railway.routes"
  },
  {
    command: "МС",
    caption: "Маршрут(ы), список Станций",
    description: "Маршрут, станции в нём, например: \033[1mМС Москва - Горячий ключ\033[22m или \033[1mМС\033[22m для всех",
    show_list_source: "@railway.routes",
    show_list_source_filter: { "title" => "" },
    object_sublist_and_title_methods: { "stations_get" => "title"}
  },
  {
    command: "М<С",
    caption: "Маршрут, вставить станцию",
    description: "Маршрут, вставить Станцию перед другой, например: \033[1mМ<С Ростов на Дону - Горячий ключ, Воронеж, Горячий ключ\033[22m",
    call_one_of_list: "@railway.routes",
    call_one_of_list_filter: { "title" => "[0]" },
    call_one_of_list_method: "station_insert",
    call_one_of_list_method_params: [{"@railway.stations" => { "title" => "[1]" }}, {"@railway.stations" => { "title" => "[2]" }}]
  },
  {
    command: "МС>",
    caption: "Маршрут, исключить станцию",
    description: "Маршрут, Станцию исключить, например: \033[1mМС> Ростов на Дону - Горячий ключ, Краснодар\033[22m",
    call_one_of_list: "@railway.routes",
    call_one_of_list_filter: { "title" => "[0]" },
    call_one_of_list_method: "station_remove",
    call_one_of_list_method_params: [{"@railway.stations" => { "title" => "[1]" }}]
  }
].freeze


MENU_HELP = MENU.map do |mi|
  " \033[1m#{mi[:command].to_s}\033[22m\t  #{mi[:description].to_s}"
end


def execute_command(menu_selected: nil, input: nil)
  puts
  puts "\033[100m \033[1m#{menu_selected[:caption]}\033[22m \033[0m"


  if menu_selected[:object_create]
    # Создать экземпляр класса с именем в :object_create, с параметрами из :object_create_params, в списке :target_list
    # object_create: "Station",  ..., target_list: "@railway.stations"

    next_command = COMMAND_INFO
    eval_command = menu_selected[:target_list] ? "#{menu_selected[:target_list]} << " : ""
    eval_command += "#{menu_selected[:object_create]}.new"

    if menu_selected[:object_create_params]
      # object_create_params: { "title" => "to_s" },
      params = menu_selected[:object_create_params]
      input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
      if params.count == input_params_values.count
        params_modificators = params.values.map(&:to_s) # например "to_i", "to_f", ...
        constructed_params = params_modificators.zip(input_params_values).map { |i| "\"#{i[1]}\"#{i[0]}" }.join(", ")
        eval_command += "(#{ constructed_params })"
      else
        puts "Не верное количество параметров, необходимо #{params.count} а именно: #{params.keys.map(&:to_s).join(", ")}"
        eval_command = ""
        next_command = ""
      end
    elsif menu_selected[:object_create_params_lookup]
      # object_create_params_lookup: { "@railway.stations" => "title", "@railway.stations" => "title" },
      params = menu_selected[:object_create_params_lookup]
      input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)

      if params.count == input_params_values.count
        constructed_params = params.map(&:last).zip(input_params_values).map { |i| "#{i[0].keys.first}.select {|obj| obj.#{i[0].values.first} == \"#{i[1]}\" }.first" }.join(", ")
        eval_command += "(#{ constructed_params })"
      else
        puts "Не верное количество параметров, необходимо #{params.count} а именно: #{params.keys.map(&:to_s).join(", ")}"
        eval_command = ""
        next_command = ""
      end
    else
      raise "Ошибка формата в MENU. В меню типа object_create должны присутствовать object_create_params или object_create_params_lookup"
    end

    target_list_after = eval(eval_command)
    if target_list_after.last.is_a?(RuntimeError)
      next_command = COMMAND_CREATE_INPUT_ERROR
      target_list_after.pop
    end
    command = next_command


  elsif menu_selected[:call_one_of_list]
    # Вызвать медот для одного объекта из списка, с параметром или без

    # command: "П<М", caption: "Назначить Поезду Маршрут",
    # description: "Поезду назначить Маршрут, например: \033[1mП<М 004, Москва - Горячий ключ\033[22m",
    # call_one_of_list: "@railway.trains",
    source = "#{menu_selected[:call_one_of_list]}"

    # user input
    input_params_values = input&.partition(' ')&.last&.squeeze(' ')&.delete(";")&.split(",")&.map(&:strip)&.reject(&:empty?) # ["004", "Москва - Горячий ключ"]

    # call_one_of_list_filter: { "number_get" => "[0]" },
    source_list_filter_method = menu_selected[:call_one_of_list_filter]&.keys&.map(&:to_s)&.first # "number_get"
    source_list_filter_value = menu_selected[:call_one_of_list_filter]&.values&.map(&:to_s)&.first # "[0]"

    eval_command = source # "@railway.trains"
    if source_list_filter_method && source_list_filter_value
      eval_command += ".find {|source_list_item| #{input_params_values.to_s}#{source_list_filter_value}.include?(source_list_item.#{source_list_filter_method})}"
      # ".find {|source_list_item| [\"004\", \"Москва - Горячий ключ\"].first.include?(source_list_item.number_get)}"
    end

    call_object = eval(eval_command) # .class = Train

    # call_one_of_list_method: "route_set",
    call_object_method = menu_selected[:call_one_of_list_method]


    # Параметры для вызываемого метода
    # call_one_of_list_method_params: [ { "@railway.routes" => { "title" => "[1]" } }, ... ]
    call_object_method_params = []
    menu_selected[:call_one_of_list_method_params]&.each do |call_one_of_list_method_param|
      call_object_method_params_object = call_one_of_list_method_param.keys.first # "@railway.routes"

      call_object_method_params_object_lookup_method = call_one_of_list_method_param.values.first.keys.first # "title"

      param_offset_in_input = call_one_of_list_method_param.values.first.values.first

      if !call_object_method_params_object.empty? && !call_object_method_params_object_lookup_method.empty?
        # объект поиска задан для параметра, поиск объекта из списка
        call_object_method_params << eval(call_object_method_params_object +
          ".find {|i| #{input_params_values.to_s}#{param_offset_in_input}.include?(i.#{call_object_method_params_object_lookup_method})}")
        # "@railway.routes.find {|params_list_item| [\"004\", \"Москва - Горячий ключ\"][1].include?(params_list_item.title)}"
      else
        # объект поиска не задан для параметра, параметр из ввода пользователя
        call_object_method_params << eval("#{input_params_values}#{param_offset_in_input}")
      end
    end

    if call_object # .class = Train
      call_object_method_result = call_object_method_params.empty? ?
        call_object.instance_eval(call_object_method) :
        call_object.send(call_object_method, *call_object_method_params)

      puts call_object_method_result if call_object_method_result.is_a?(String)
    end
    command = COMMAND_INFO


  elsif menu_selected[:show_list_source]
    # Отобразить список, со списком вложенных объектов
    # show_list_source: "@railway.stations", show_list_source_filter: { "title" => "" }, object_sublist_and_title_methods: { "trains_get" => "number_get"}
    # show_list_source: "@railway.trains", show_list_source_filter: { "number_get" => "" }

    eval_command = "#{menu_selected[:show_list_source]}"
    input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
    source_list_filter_method = menu_selected[:show_list_source_filter].keys.map(&:to_s).first if menu_selected[:show_list_source_filter]
    if source_list_filter_method && (input_params_values.count > 0)
      puts " только для: #{input_params_values.join(", ")}"
      eval_command += ".select {|source_list_item| #{input_params_values.to_s}.include?(source_list_item.#{source_list_filter_method})}"
    end
    source_list_result = eval(eval_command)

    puts
    source_list_result.each do |source_list_item|
      puts "  \033[1m#{source_list_item.send(source_list_filter_method)}\033[22m"

      # object_sublist_and_title_methods: { "route_get" => "title"}
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
  if command == COMMAND_CREATE_INPUT_ERROR
    puts "\033[0;31m Неправильный ввод при создании\033[0m\t"
    command = ""
  end

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
    puts "\033[0;31mНеизвестная команда\033[0m\t"
    next
  end

  next_command = execute_command(menu_selected: menu_selected, input: input)
  command = command == next_command ? "" : next_command
end

puts
