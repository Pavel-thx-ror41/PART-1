# frozen_string_literal: false

def exec_object_create_menu_params(menu_selected)
  [
    menu_selected[:target_list],
    menu_selected[:object_create],
    menu_selected[:object_create_params],
    menu_selected[:object_create_params_lookup]
  ]
end

def wrong_parameters_count_alert(object_create_params)
  puts "Не верное количество параметров, необходимо #{object_create_params.count}" \
       " а именно: #{object_create_params.keys.map(&:to_s).join(', ')}"
  '' # next_command
end

def object_create_params_make_eval_string(input_params_values, object_create_params)
  params_modificators = object_create_params.values.map(&:to_s) # например "to_i", "to_f", ...
  constructed_params = params_modificators.zip(input_params_values).map { |i| "\"#{i[1]}\"#{i[0]}" }.join(', ')
  "(#{constructed_params})"
end

def object_create_params_lookup_make_eval_string(input_params_values, object_create_params_lookup)
  constructed_params = object_create_params_lookup.map(&:last).zip(input_params_values).map do |i|
    "#{i[0].keys.first}.select {|obj| obj.#{i[0].values.first} == \"#{i[1]}\" }.first"
  end.join(', ')
  "(#{constructed_params})"
end

# execute UI command -> object_create
def exec_object_create(target_list, object_create, object_create_params, object_create_params_lookup,
                       input_params_values)
  # object_create: 'Station',
  # target_list: '@railway.stations'
  eval_command = target_list ? "#{target_list} << #{object_create}.new" : "#{object_create}.new"

  if object_create_params
    # object_create_params: { 'title' => ".squeeze(' ').strip" },
    # object_create_params: { "title" => "to_s" },

    return wrong_parameters_count_alert(object_create_params) unless # return next_command = ''
      object_create_params.count.eql?(input_params_values.count)

    eval_command += object_create_params_make_eval_string(input_params_values, object_create_params)
  elsif object_create_params_lookup
    # object_create_params_lookup: { "@railway.stations" => "title", "@railway.stations" => "title" },
    # object_create_params_lookup: { 'from' => { '@railway.stations' => 'title' },
    #                                'to' => { '@railway.stations' => 'title' } },
    return wrong_parameters_count_alert(object_create_params_lookup) unless # return next_command = ''
      object_create_params_lookup.count.eql?(input_params_values.count)

    eval_command += object_create_params_lookup_make_eval_string(input_params_values, object_create_params_lookup)
  else
    raise 'Ошибка описания меню (ui_menu.rb).' \
          ' В меню типа object_create должны присутствовать object_create_params или object_create_params_lookup'
  end

  eval(eval_command)
  COMMAND_INFO # next_command
rescue StandardError => e
  [COMMAND_EXECUTE_ERROR, e.message]
end

def exec_call_one_of_list_menu_params(menu_selected)
  [
    [ # Условия выборки объекта из списка
      menu_selected[:call_one_of_list].to_s,                               # objects list: "@railway.trains"
      menu_selected[:call_one_of_list_filter]&.keys&.map(&:to_s)&.first,   # "number_get" from { "number_get" => "[0]" }
      menu_selected[:call_one_of_list_filter]&.values&.map(&:to_s)&.first  # "[0]"        from { "number_get" => "[0]" }
    ],
    [ # Метод и параметры вызываемые на объекте
      menu_selected[:call_one_of_list_method],
      # call_one_of_list_method: "route_set",
      menu_selected[:call_one_of_list_method_params]
      # call_one_of_list_method_params: [ { "@railway.routes" => { "title" => "[1]" } }, ... ]
    ]
  ]
end

# Получаем объект, методы которого будем вызывать
def exec_call_one_of_list_get_object(object_from_list, input_params_values)
  objects_list_eval_source, object_list_filter_method, object_list_filter_input_value = object_from_list
  # menu_selected[:call_one_of_list].to_s,
  #   objects list: "@railway.trains"
  # menu_selected[:call_one_of_list_filter]&.keys&.map(&:to_s)&.first,
  #   "number_get" from { "number_get" => "[0]" }
  # menu_selected[:call_one_of_list_filter]&.values&.map(&:to_s)&.first,
  #   "[0]"        from { "number_get" => "[0]" }

  if object_list_filter_method && object_list_filter_input_value
    objects_list_eval_source += '.find {|source_list_item|' \
                                " #{input_params_values}#{object_list_filter_input_value}.include?" \
                                "(source_list_item.#{object_list_filter_method})}"
    # ".find {|source_list_item| [\"004\", \"Москва - Горячий ключ\"].first.include?(source_list_item.number_get)}"
  end

  eval(objects_list_eval_source) # .class = Train
end

# Получаем сами объекты, далее используемые в качестве параметров
def exec_call_one_of_list_get_params_objects(menu_call_object_method_params, input_params_values)
  call_object_method_params_objects = []
  menu_call_object_method_params&.each do |call_one_of_list_method_param|
    call_object_method_params_object = call_one_of_list_method_param.keys.first # "@railway.routes"

    call_object_method_params_object_lookup_method = call_one_of_list_method_param.values.first.keys.first # "title"

    param_offset_in_input = call_one_of_list_method_param.values.first.values.first

    if !call_object_method_params_object.empty? && !call_object_method_params_object_lookup_method.empty?
      # объект поиска задан для параметра, поиск объекта из списка
      call_object_method_params_objects << eval(
        call_object_method_params_object +
        ".find {|i| #{input_params_values}#{param_offset_in_input}.include?" \
        "(i.#{call_object_method_params_object_lookup_method})}"
      )
      # "@railway.routes.find {|params_list_item|
      #   [\"004\", \"Москва - Горячий ключ\"][1].include?(params_list_item.title)}"
    else
      # объект поиска не задан для параметра, параметр из ввода пользователя
      eval_source_code = "#{input_params_values}#{param_offset_in_input}"
      call_object_method_params_objects << eval(eval_source_code)
    end
  end

  call_object_method_params_objects
end

# command: "П<М", caption: "Назначить Поезду Маршрут",
# description: "Поезду назначить Маршрут, например: \033[1mП<М 008-АИ, Москва - Горячий ключ\033[22m",
# call_one_of_list: "@railway.trains", ...
def exec_call_one_of_list(object_from_list, object_call_method, input_params_values)
  menu_call_object_method, menu_call_object_method_params = object_call_method
  # menu_selected[:call_one_of_list_method],
  # call_one_of_list_method: "route_set",
  # menu_selected[:call_one_of_list_method_params]
  # call_one_of_list_method_params: [ { "@railway.routes" => { "title" => "[1]" } }, ... ]

  object_to_call = exec_call_one_of_list_get_object(object_from_list, input_params_values)
  raise "Ошибка. Не найден оъект '#{input_params_values[0]}' в '#{object_from_list[0]}'" unless object_to_call

  # Параметры (объекты) для вызываемого метода
  call_object_method_params_objects =
    exec_call_one_of_list_get_params_objects(menu_call_object_method_params, input_params_values)

  # object_to_call.class = Train
  # Вызываем метод с параметрами или без
  call_object_method_result = if call_object_method_params_objects.empty?
                                object_to_call.instance_eval(menu_call_object_method)
                              else
                                object_to_call.send(menu_call_object_method, *call_object_method_params_objects)
                              end

  puts call_object_method_result if call_object_method_result.is_a?(String) # RailWay.status
  COMMAND_INFO
rescue StandardError => e
  [COMMAND_EXECUTE_ERROR, e.message || 'Неизвестная ошибка']
end

def exec_show_list_menu_params(menu_selected)
  [
    menu_selected[:show_list_source].to_s,
    menu_selected[:show_list_source_each_call],
    menu_selected[:object_sublist_and_title_methods]
  ]
end

# show_list_source: '@railway.routes',
# show_list_source_each_call: 'title',
# object_sublist_and_title_methods: { 'stations_get' => 'sublist_item.title' }
def exec_show_list(show_list_source, show_list_source_each_call, object_sublist_and_title_methods, input_params_values)
  # исходный список
  eval_command = show_list_source
  if show_list_source_each_call && input_params_values.count.positive?
    # дополнительная фильтрация
    puts " только для: #{input_params_values.join(', ')}"
    eval_command += ".select {|source_list_item| #{input_params_values}." \
                    "include?(source_list_item.#{show_list_source_each_call})}"
  end
  source_list_result = eval(eval_command)

  puts
  # элементы списка
  source_list_result.each do |source_list_item|
    puts "  \033[1m#{source_list_item.instance_eval(show_list_source_each_call)}\033[22m"

    # object_sublist_and_title_methods: { "route_get" => "sublist_item.title"}
    next unless object_sublist_and_title_methods

    # вложенный список
    eval_command = "source_list_item.#{object_sublist_and_title_methods.keys.first}.map" \
                   " {|sublist_item| #{object_sublist_and_title_methods.values.first} }"
    sub_list = eval(eval_command)
    puts "   #{sub_list.join("\r\n   ")}" if sub_list.count.positive?
    puts
  end
  ''
rescue StandardError => e
  [COMMAND_EXECUTE_ERROR, e.message]
end

def execute_ui_command(menu_selected, input)
  puts
  puts "\033[100m \033[1m#{menu_selected[:caption]}\033[22m \033[0m"
  if menu_selected[:object_create]
    # Создать экземпляр класса с именем в :object_create, с параметрами из :object_create_params, в списке :target_list
    exec_object_create(*exec_object_create_menu_params(menu_selected), input)

  elsif menu_selected[:call_one_of_list]
    # Вызвать метод для одного объекта из списка, с параметром или без
    exec_call_one_of_list(*exec_call_one_of_list_menu_params(menu_selected), input)

  elsif menu_selected[:show_list_source]
    # Отобразить список, со списком вложенных объектов
    exec_show_list(*exec_show_list_menu_params(menu_selected), input)

  else
    [COMMAND_EXECUTE_ERROR, 'Не реализовано']

  end
end
