#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  Программа
    запрашивает у пользователя имя и рост и
    выводит идеальный вес по формуле (<рост> - 110) * 1.15, после чего
    выводит результат пользователю на экран с обращением по имени.
    Если идеальный вес получается отрицательным, то выводится строка "Ваш вес уже оптимальный"
=end

name = nil
height = nil


while name.to_s.empty?
  print "введите имя: "
  name = gets.chomp.to_s
end  

while not height.to_f.positive?
  print "введите рост: "
  height = gets.chomp.to_f
end


ideal_weight = ((height - 110.0) * 1.15).round(2)

if ideal_weight.negative?
  puts "#{name}, ваш вес уже оптимальный"
else
  puts "#{name}, ваш идеальный вес: #{ideal_weight}"
end
