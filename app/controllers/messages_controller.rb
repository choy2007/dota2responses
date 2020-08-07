class MessagesController < ApplicationController
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.new(message_params)
    @message.user = current_user
    
    if @message.save
      SendMessageJob.perform_later(@message)
    else
      redirect_to(fallback_location: root_path)
    end
  end
  
  private
  
  def message_params
    params.require(:message).permit(:content)
  end
end
