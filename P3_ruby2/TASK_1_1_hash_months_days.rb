#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  1. Сделать хеш, содержащий месяцы и количество дней в месяце.
  В цикле выводить те месяцы, у которых количество дней ровно 30
=end


puts "Хэш с месяцами в 30 дней"

months = {
  january: 31,
  february: 28,
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

months.
  select{|title, length| length == 30}.
    each_key { |title|
      puts title
}
