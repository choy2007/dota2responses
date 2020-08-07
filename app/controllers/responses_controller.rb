class ResponsesController < ApplicationController
  def index
    @hero_responses = Hero.find_by(name: params[:name]).responses.pluck(:title)

    respond_to do |format|
      format.js
    end
  end
  
  def chat_wheel
    @chat_wheel_responses = Event.find_by(name: params[:name]).responses.pluck(:title)
    
    respond_to do |format|
      format.js
    end
  end
end
