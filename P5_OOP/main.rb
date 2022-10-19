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
    command: "П+",
    caption: "Добавление Поезда",
    description: "Поезд создать, например: \033[1mП+ 007,ПАСС\033[22m или \033[1mП+ 007,ГРУЗ\033[22m",
    object_create: "Train",
    object_create_params: {
      "number" => ".squeeze(' ').strip",
      "type" => ".strip.chars.first.upcase.gsub(\"Г\", \"cargo\").gsub(\"П\", \"passenger\").to_sym"
    },
    target_list: "@railway.trains"
  },
  {
    command: "П<М",
    caption: "Назначить Поезду Маршрут",
    description: "Поезду назначить Маршрут, например: \033[1mП<М 004, Москва - Горячий ключ\033[22m",
    call_one_of_list_source: "@railway.trains",
    call_one_of_list_source_filter: { "number_get" => ".first" },
    call_one_of_list_method: "route_set",
    call_one_of_list_method_param: "@railway.routes",
    call_one_of_list_method_param_filter: { "title" => "[1]" }
  },

  # { command: :ПМВ, description: "Перемещать поезд по маршруту вперед и", params: "", list: nil },
  # { command: :ПМН, description: "Перемещать поезд по маршруту назад", params: "", list: nil },
  #
  # { command: :ПВ+, description: "Добавлять вагоны к поезду", params: "", list: nil },
  # { command: :ПВ+, description: "Отцеплять вагоны от поезда", params: "", list: nil },


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

  # { command: :МС+, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil },
  # { command: :МС-, description: "управлять станциями в нем (добавлять, удалять)", params: "", list: nil }


  { caption: " " }

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
        binding.pry # . ?   constructed_params
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
      raise "Ошибка данных. В меню типа object_create должны присутствовать object_create_params или object_create_params_lookup"
    end

    eval(eval_command)
    command = next_command


  elsif menu_selected[:call_one_of_list_source] && menu_selected[:call_one_of_list_method]
    # Вызвать медот для одного объекта из списка, с параметром или без
    # call_one_of_list_source: "@railway.trains",
    eval_command = "#{menu_selected[:call_one_of_list_source]}"
    # call_one_of_list_source_filter: { "number_get" => ".first" ),
    source_list_filter_method = menu_selected[:call_one_of_list_source_filter].keys.map(&:to_s).first
    input_params_values = input.partition(' ').last.squeeze(' ').delete(";").split(",").map(&:strip).reject(&:empty?)
    source_list_filter_value = menu_selected[:call_one_of_list_source_filter].values.map(&:to_s).first
    eval_command += ".find {|source_list_item| #{input_params_values.to_s}#{source_list_filter_value}.include?(source_list_item.#{source_list_filter_method})}"
    call_object = eval(eval_command)

    # Параметры для вызываемого метода
    # call_one_of_list_method_param: "@railway.routes",
    if menu_selected[:call_one_of_list_method_param]
      # call_one_of_list_method_param_filter: { "title" => "[1]" }
      param_object_lookup_method = menu_selected[:call_one_of_list_method_param_filter].keys.first
      param_offset_in_input = menu_selected[:call_one_of_list_method_param_filter].values.first
      eval_command_params = menu_selected[:call_one_of_list_method_param] +
        ".find {|params_list_item| #{input_params_values.to_s}#{param_offset_in_input}.include?(params_list_item.#{param_object_lookup_method})}"

      params_object = eval(eval_command_params)
    end

    # call_one_of_list_method: "route_set",
    if call_object
      call_result = params_object ?
                    call_object.send(menu_selected[:call_one_of_list_method], params_object) :
                    call_object.send(menu_selected[:call_one_of_list_method])
                    # TODO pass or not params not according params_object, but menu_selected[:call_one_of_list_method_param_filter].values.count
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
