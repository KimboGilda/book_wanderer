class CreateBookstores < ActiveRecord::Migration[7.1]
  def change
    create_table :bookstores do |t|
      t.text :name
      t.text :address
      t.boolean :availability

      t.timestamps
    end
  end
end
