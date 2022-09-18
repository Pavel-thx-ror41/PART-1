#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
  Квадратное уравнение

  Пользователь вводит 3 коэффициента a, b и с.
  Программа вычисляет дискриминант (D)
    и корни уравнения (x1 и x2, если они есть)
    и выводит значения дискриминанта и корней на экран.
  При этом возможны следующие варианты:
    Если D > 0, то выводим дискриминант и 2 корня                                    # 1,3,1
    Если D = 0, то выводим дискриминант и 1 корень (т.к. корни в этом случае равны)  # 2,4,2; 1,2,1
    Если D < 0, то выводим дискриминант и сообщение "Корней нет"                     # 3,1,3
  Подсказка: Алгоритм решения с блок-схемой:
             http://www.bolshoyvopros.ru/questions/299829-kak-sostavit-algoritm-reshenija-kvadratnogo-uravnenija.html
             Для вычисления квадратного корня, нужно использовать Math.sqrt
             https://www.alanwsmith.com/posts/convert-a-ruby-array-into-the-keys-of-a-new-hash--20en5tdxvwff
=end


puts "Квадратное уравнение"

coefficients = {a: nil, b: nil, c: nil}

coefficients.each_key { |key|
  coefficient = ""
  while not coefficient.to_f.positive?
    print " введите коэффициент  #{key} = "
    coefficient = gets.chomp.to_f
  end
  coefficients[key] = coefficient
}

discriminant = coefficients[:b]**2 - 4 * coefficients[:a] * coefficients[:c]
puts "Дискриминант = #{discriminant}"


case
when discriminant > 0
  printf "D>0 Уравнение имеет два корня"
  discriminant_sqrt = Math.sqrt(discriminant)
  printf ": #{(-coefficients[:b]+discriminant_sqrt) / (2*coefficients[:a])}"
  puts   ", #{(-coefficients[:b]-discriminant_sqrt) / (2*coefficients[:a])}"

when discriminant == 0
  puts "D=0 Уравнение имеет один корнь: #{-coefficients[:b] / (2*coefficients[:a])}"

when discriminant < 0
  puts "D<0 Уравнение не имеет корней"
end
