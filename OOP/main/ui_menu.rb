CLS = "\e[H\e[2J"
COMMAND_INFO = "Д"
COMMAND_EXECUTE_ERROR = "ОШИБКА_ВЫПОЛНЕНИЯ_КОМАНДЫ"
COMMAND_EXIT = "Х"

MENU = [
  {
    command: COMMAND_INFO,
    caption: "Диспетчерская",
    description: "Диспетчерская (посмотреть всю дорогу)",
    call_one_of_list: "@railway",
    call_one_of_list_method: "status"
  },


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
    description: "Поезд создать (Пассажирский), например: \033[1mП+П 007-АЖ\033[22m",
    object_create: "PassengerTrain",
    object_create_params: { "number" => ".squeeze(' ').strip" },
    target_list: "@railway.trains"
  },
  {
    command: "П+Г",
    caption: "Добавление ГрузовогоПоезда",
    description: "Поезд создать (Грузовой), например: \033[1mП+Г 009-АИ\033[22m",
    object_create: "CargoTrain",
    object_create_params: { "number" => ".squeeze(' ').strip" },
    target_list: "@railway.trains"
  },
  {
    command: "П<М",
    caption: "Назначить Поезду Маршрут",
    description: "Поезду назначить Маршрут, например: \033[1mП<М 04Г-ЖГ, Москва - Горячий ключ\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_set",
    call_one_of_list_method_params: [ { "@railway.routes" => { "title" => "[1]" } } ]
  },
  {
    command: "ПМВ",
    caption: "Поезд по Маршруту вперёд",
    description: "Поезд по Маршруту вперёд, например: \033[1mПМВ 03В-АВ\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_move_next_station",
  },
  {
    command: "ПМН",
    caption: "Поезд по Маршруту назад",
    description: "Поезд по Маршруту назад, например: \033[1mПМН 03В-АВ\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "route_move_prev_station",
  },
  {
    command: "ПВ+П",
    caption: "Поезд Вагон добавить пассажирский",
    description: "Поезд Вагон пассажирский добавить, например: \033[1mПВ+П 01А-0А\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_add(PassengerWagon.new)",
  },
  {
    command: "ПВ+Г",
    caption: "Поезд Вагон добавить грузовой",
    description: "Поезд Вагон грузовой добавить, например: \033[1mПВ+Г 02Б-0Б\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_add(CargoWagon.new)",
  },
  {
    command: "ПВ-",
    caption: "Поезд Вагон отцепить",
    description: "Поезд Вагон отцепить, например: \033[1mПВ- 02Б-0Б\033[22m",
    call_one_of_list: "@railway.trains",
    call_one_of_list_filter: { "number_get" => "[0]" },
    call_one_of_list_method: "wagon_remove",
  },


  {
    command: "М",
    caption: "Маршруты",
    description: "Маршруты, посмотреть список",
    show_list_source: "@railway.routes",
    show_list_source_filter: { "title" => "" }
  },
  {
    command: "М+",
    caption: "Маршрут создать",
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
