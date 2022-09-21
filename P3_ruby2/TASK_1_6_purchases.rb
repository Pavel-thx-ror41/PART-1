#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  6. Сумма покупок.
    Пользователь вводит поочередно
      название товара,
      цену за единицу и
      кол-во купленного товара (может быть нецелым числом).

      Пользователь может ввести произвольное кол-во товаров до тех пор,
        пока не введет "стоп" в качестве названия товара.

    На основе введенных данных требуетеся:
     - Заполнить и вывести на экран
        хеш, ключами которого являются названия товаров,
        а значением - вложенный хеш, содержащий
          цену за единицу товара и
          кол-во купленного товара.
        Также вывести итоговую сумму за каждый товар.
     - Вычислить и вывести на экран итоговую сумму всех покупок в "корзине".
=end


puts "Сумма покупок"


cart = {}
loop do
  puts
  print " Введите название: "
  title = gets.chomp
  break if title == "стоп"

  print " Введите цену за единицу: "
  price = gets.chomp.to_f

  print " Введите количество: "
  volume = gets.chomp.to_f

  if cart[title]
    if cart[title][price]
      cart[title][price] += volume
    else
      cart[title].merge!({ price => volume })
    end
  else
    cart[title] = { price => volume }
  end

  # puts
  # puts cart
  # puts
end

# cart = {"ХЛЕБ"=>{30.0=>0.5, 50.0=>0.8, 70.0=>0.5}, "МАСЛО"=>{400.0=>0.25, 500.0=>0.25}, "СЫР"=>{700.0=>0.5, 1200.0=>0.7}, "ВИНО"=>{400.0=>0.7}}

totals = {}
cart.each do |title, items|
  # puts
  # puts title
  items.each do |price, volume|
    # puts "#{price} #{volume}"
    if totals[title]
      totals[title] += price * volume
    else
      totals[title] = price * volume
    end
  end
end

puts
puts "Затраты по позициям: #{totals.to_s.gsub(/{|}|"/,"").gsub(/=>/,":")}"
puts "Общий итог: #{totals.values.sum}"
puts
