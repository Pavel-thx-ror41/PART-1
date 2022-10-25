class PassengerTrain < Train
  def wagon_add(wagon)
    @wagons << wagon if @speed == 0 && wagon.class.to_s.gsub('Wagon','') == self.class.to_s.gsub('Train','')
  end
end