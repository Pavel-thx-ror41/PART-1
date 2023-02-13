class CargoWagon < Wagon
  def initialize(*capacity_total)
    @capacity_total = capacity_total.first || 50.0
    @capacity_used = 0
  end
end
