# typed: true
class CreateMakes < ActiveRecord::Migration[6.0]
  def change
    create_table :makes do |t|
      t.text :what_will_i_make

      t.timestamps
    end
  end
end
