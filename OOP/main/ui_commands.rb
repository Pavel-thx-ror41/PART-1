# frozen_string_literal: false

# execute UI command -> object_create
def exec_object_create(menu_selected, input_params_values)
  next_command = COMMAND_INFO
  eval_command = menu_selected[:target_list] ? "#{menu_selected[:target_list]} << " : ''
  eval_command += "#{menu_selected[:object_create]}.new"

  if menu_selected[:object_create_params]
    # object_create_params: { "title" => "to_s" },
    params = menu_selected[:object_create_params]
    if params.count == input_params_values.count
      params_modificators = params.values.map(&:to_s) # например "to_i", "to_f", ...
      constructed_params = params_modificators.zip(input_params_values).map { |i| "\"#{i[1]}\"#{i[0]}" }.join(', ')
      eval_command += "(#{constructed_params})"
    else # TODO: exctract method
      puts "Не верное количество параметров, необходимо #{params.count}" \
           " а именно: #{params.keys.map(&:to_s).join(', ')}"
      eval_command = ''
      next_command = ''
    end
  elsif menu_selected[:object_create_params_lookup]
    # object_create_params_lookup: { "@railway.stations" => "title", "@railway.stations" => "title" },
    params = menu_selected[:object_create_params_lookup]

    if params.count == input_params_values.count
      constructed_params = params.map(&:last).zip(input_params_values).map do |i|
        "#{i[0].keys.first}.select {|obj| obj.#{i[0].values.first} == \"#{i[1]}\" }.first"
      end.join(', ')
      eval_command += "(#{constructed_params})"
    else
      puts "Не верное количество параметров, необходимо #{params.count}" \
           " а именно: #{params.keys.map(&:to_s).join(', ')}"
      eval_command = ''
      next_command = ''
    end
  else
    raise 'Ошибка формата в MENU.' \
          ' В меню типа object_create должны присутствовать object_create_params или object_create_params_lookup'
  end

  eval(eval_command)
  next_command
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

def exec_show_list(menu_selected, input_params_values)
  eval_command = menu_selected[:show_list_source].to_s
  source_list_each_call = menu_selected[:show_list_source_each_call] if menu_selected[:show_list_source_each_call]
  if source_list_each_call && input_params_values.count.positive?
    puts " только для: #{input_params_values.join(', ')}"
    eval_command += ".select {|source_list_item| #{input_params_values}." \
                    "include?(source_list_item.#{source_list_each_call})}"
  end
  source_list_result = eval(eval_command)

  puts
  source_list_result.each do |source_list_item|
    puts "  \033[1m#{source_list_item.instance_eval(source_list_each_call)}\033[22m"

    # object_sublist_and_title_methods: { "route_get" => "sublist_item.title"}
    next unless menu_selected[:object_sublist_and_title_methods]

    eval_command = "source_list_item.#{menu_selected[:object_sublist_and_title_methods].keys.first}.map" \
                   " {|sublist_item| #{menu_selected[:object_sublist_and_title_methods].values.first} }"
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
    # object_create: "Station",  ..., target_list: "@railway.stations"
    ### exec_object_create(menu_selected, input_parse_params(input))
    exec_object_create(menu_selected, input)

  elsif menu_selected[:call_one_of_list]
    # Вызвать метод для одного объекта из списка, с параметром или без
    exec_call_one_of_list(*exec_call_one_of_list_menu_params(menu_selected), input)

  elsif menu_selected[:show_list_source]
    # Отобразить список, со списком вложенных объектов
    # show_list_source: "@railway.stations", show_list_source_each_call: "title",
    #   object_sublist_and_title_methods: { "trains_get" => "sublist_item.number_get"}
    # show_list_source: "@railway.trains", show_list_source_each_call: "number_get"
    exec_show_list(menu_selected, input)

  else
    [COMMAND_EXECUTE_ERROR, 'Не реализовано']

  end
end
