class CreateResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :responses do |t|
      t.string :title
      t.string :sound
      
      t.timestamps
    end
  end
end
