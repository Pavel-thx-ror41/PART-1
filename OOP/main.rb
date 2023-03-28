#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way'
require_relative 'main/ui_menu'
require_relative 'main/ui_commands'

@railway = RailWay.new(do_seed: true)

puts CLS
command = COMMAND_INFO
error_message = ''

loop do
  if command == COMMAND_EXECUTE_ERROR
    puts "\033[0;31m ОШИБКА: #{error_message}\033[0m\t"
    command = ''
  end

  if command == ''
    puts
    print 'введите команду: ' # "ПВ< 02Б-0Б, 1, 12"
    input = gets.chomp
    command = input.partition(' ').first.to_s.strip.upcase # "ПВ<"
    input = input.partition(' ').last.to_s.squeeze(' ').delete(';').split(',').map(&:strip).reject(&:empty?)
    # ["02Б-0Б", "1", "12"]
  end
  puts CLS

  puts "\033[30;47m Команда  Описание \033[39;49m"
  puts MENU_HELP
  puts "\033[1m #{COMMAND_EXIT}\033[22m\t  Выход"

  break if command.eql?(COMMAND_EXIT)

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }

  if menu_selected.nil?
    command = ''
    puts
    puts "\033[0;31mНеизвестная команда\033[0m\t"
    next
  end

  next_command, error_message = execute_command(menu_selected, input)
  command = command.eql?(next_command) ? '' : next_command
end

puts
