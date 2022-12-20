#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require_relative 'rail_way.rb'
require_relative 'main/ui_menu.rb'
require_relative 'main/ui_commands.rb'

@railway = RailWay.new(seed: true)

puts CLS
command = COMMAND_INFO
error_message = ""

loop do
  if command == COMMAND_EXECUTE_ERROR
    puts "\033[0;31m ОШИБКА: #{error_message}\033[0m\t"
    command = ""
  end


  if command == ""
    puts
    print "введите команду: "
    input = gets.chomp
    command = input.partition(' ').first.strip.upcase
  end
  puts CLS

  puts "\033[30;47m Команда  Описание \033[39;49m"
  puts MENU_HELP
  puts "\033[1m #{COMMAND_EXIT}\033[22m\t  Выход"

  break if command == COMMAND_EXIT

  menu_selected = MENU.find { |mi| mi[:command] == command.to_s }

  if menu_selected.nil?
    command = ""
    puts
    puts "\033[0;31mНеизвестная команда\033[0m\t"
    next
  end

  next_command, error_message = execute_command(menu_selected: menu_selected, input: input)
  command = command == next_command ? "" : next_command
end

puts
