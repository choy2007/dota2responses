class RoomController < ApplicationController
  def index
    @heroes = Hero.pluck(:name)
    @events = Event.pluck(:name)
    
    @message = Message.new
    @messages = Message.all
  end
end