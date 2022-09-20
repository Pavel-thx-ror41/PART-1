#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  4. Заполнить хеш гласными буквами,
  где значением будет являтся порядковый номер буквы в алфавите (a - 1).
=end

puts "Хеш гласных букв"


vowels = {}

(:a..:z).to_a.each_with_index { |letter, index|
  vowels[letter] = index+1 if [:a, :e, :i, :o, :u].include?(letter)
}
