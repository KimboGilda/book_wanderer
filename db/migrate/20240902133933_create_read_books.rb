class CreateReadBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :read_books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
