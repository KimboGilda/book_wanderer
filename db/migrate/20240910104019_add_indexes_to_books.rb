class AddIndexesToBooks < ActiveRecord::Migration[7.1]
  def change
    add_index :books, :title
    add_index :books, :author
    add_index :books, :publication_year
  end
end
