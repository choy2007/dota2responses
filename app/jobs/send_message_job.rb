class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    current_user_message = ApplicationController.render(partial: 'messages/current_user_message', locals: {message: message})
    other_users_message = ApplicationController.render(partial: 'messages/other_users_message', locals: {message: message})

    ActionCable.server.broadcast('room_channel',
      current_user_message: current_user_message,
      other_users_message: other_users_message,
      message: message
    )
  end
end
