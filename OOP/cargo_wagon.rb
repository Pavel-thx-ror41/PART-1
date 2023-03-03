class CargoWagon < Wagon
  def initialize(*capacity_total)
    @capacity_total = capacity_total.first || 50.0
    @capacity_used = 0
  end

  def capacity_take(volume)
    super(volume.to_f)
  end
end
