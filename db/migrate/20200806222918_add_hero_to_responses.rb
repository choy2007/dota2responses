class AddHeroToResponses < ActiveRecord::Migration[6.0]
  def change
    add_reference :responses, :hero
  end
end
