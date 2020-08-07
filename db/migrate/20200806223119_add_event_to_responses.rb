class AddEventToResponses < ActiveRecord::Migration[6.0]
  def change
    add_reference :responses, :event
  end
end
