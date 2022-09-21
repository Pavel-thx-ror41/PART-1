#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  5. Заданы три числа, которые обозначают число, месяц, год (запрашиваем у пользователя).
  Найти порядковый номер даты, начиная отсчет с начала года. Учесть, что год может быть високосным.
  (Запрещено использовать встроенные в ruby методы для этого вроде Date#yday или Date#leap?)
  Алгоритм опредления високосного года:
    https://docs.microsoft.com/ru-ru/office/troubleshoot/excel/determine-a-leap-year

      1 Если год делится на 4 без остатка,   перейдите на шаг 2  В противном случае 365
      2 Если год делится на 100 без остатка, перейдите на шаг 3  В противном случае 366
      3 Если год делится на 400 без остатка, 366                 В противном случае 365

      =IF( OR(   MOD(A1,400)=0,
                 AND( MOD(A1,4)=0, MOD(A1,100)<>0 )
           )
      ,"Leap Year", "NOT a Leap Year" )
=end


puts "Порядковый номер дня с начала года"


year = 0
until year >= 1 do
  print " Введите год: "
  year = gets.chomp.to_i
end

year_months = {
  january: 31,
  february: ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) ? 29 : 28,
  march: 31,
  april: 30,
  may: 31,
  june: 30,
  july: 31,
  august: 31,
  september: 30,
  october: 31,
  november: 30,
  december: 31
}

month = 0
until month >= 1 && month <= 12
  print " Введите месяц: "
  month = gets.chomp.to_i
end

day = 0
until day >= 1 && day <= year_months.values[month-1]
  print " Введите день: "
  day = gets.chomp.to_i
end


day_num = 0
(1...month).each do |month|
  day_num += year_months.values[month-1]
end
day_num += day

puts "Порядковый номер дня, введённой даты, с начала года: #{day_num}"
