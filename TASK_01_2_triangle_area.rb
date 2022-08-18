#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  Площадь треугольника.
    Площадь треугольника можно вычислить, зная его основание (a) и высоту (h) по формуле: 1/2*a*h.
    Программа должна запрашивать основание и высоту треугольника и возвращать его площадь.
=end

puts "Программа расчёта площади треугольника"


base = nil
height = nil

while not base.to_f.positive?
  print "введите длину основания треугольника: "
  base = gets.chomp.to_f
end

while not height.to_f.positive?
  print "введите высоту основания треугольника: "
  height = gets.chomp.to_f
end


puts "Площадь треугольника равна #{0.5 * base * height}"
