#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  3. Заполнить массив числами фибоначчи до 100
=end

puts "Массив с числами фибоначчи до 100"

array2 = [0, 1]
(2..100).each {|i|
  array2[i] = array2[i-1] + array2[i-2]
}
