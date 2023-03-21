# frozen_string_literal: false

class PassengerWagon < Wagon
  # rubocop:disable Lint/MissingSuper
  def initialize(*capacity_total)
    @capacity_total = capacity_total.first || 36
    @capacity_used = 0
  end
  # rubocop:enable Lint/MissingSuper

  def capacity_take_one
    capacity_take(1)
  end

  def capacity_take(volume)
    super(volume.round.to_i)
  end
end
