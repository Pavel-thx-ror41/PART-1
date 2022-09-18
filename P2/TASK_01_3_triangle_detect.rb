#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  Прямоугольный треугольник.
    Программа запрашивает у пользователя 3 стороны треугольника и определяет, является ли треугольник
    - прямоугольным (используя теорему Пифагора www-formula.ru),
    - равнобедренным (т.е. у него равны любые 2 стороны) или
    - равносторонним (все 3 стороны равны) и
    выводит результат на экран.
    Подсказка: чтобы воспользоваться теоремой Пифагора, нужно сначала найти самую длинную сторону (гипотенуза) и
               сравнить ее значение в квадрате с суммой квадратов двух остальных сторон. Если все 3 стороны равны,
               то треугольник равнобедренный и равносторонний, но не прямоугольный.
=end

puts "Программа определяет треугольник прямоугольный, равнобедренным или равносторонний"


triangle_sides = []

3.times do |i|
  length = ""
  while not length.to_f.positive?
    print "введите длину стороны треугольника №#{i+1}: "
    length = gets.chomp.to_f
  end
  triangle_sides << length
end

triangle_sides.sort!

case
when triangle_sides.uniq.length == 1
  puts "Это равнобедренный и равносторонний треугольник (все стороны одинаковой длины)"
when triangle_sides.uniq.length == 2
  puts "Это равнобедренный треугольник (две стороны одинаковой длины)"
when triangle_sides[0]**2 + triangle_sides[1]**2 == triangle_sides[-1]**2
  puts "Это прямоугольный треугольник (имеющий угол 90°)" # 6,8,10
else
  puts "Это обычный треугольник"
end
