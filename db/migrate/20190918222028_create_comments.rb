# typed: true
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :banal_brainstorm
      t.text :comment_text
      t.integer :parent_id

      t.timestamps
    end
    add_index :comments, :parent_id, unique: true
  end
end
