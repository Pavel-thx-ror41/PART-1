# frozen_string_literal: false

class CargoWagon < Wagon
  # rubocop:disable Lint/MissingSuper
  def initialize(*capacity_total)
    @capacity_total = capacity_total.first || 50.0
    @capacity_used = 0
  end
  # rubocop:enable Lint/MissingSuper

  def capacity_take(volume)
    super(volume.to_f)
  end
end
