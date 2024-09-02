class CreateBookstorebooks < ActiveRecord::Migration[7.1]
  def change
    create_table :bookstorebooks do |t|
      t.references :book, null: false, foreign_key: true
      t.references :bookstore, null: false, foreign_key: true

      t.timestamps
    end
  end
end
