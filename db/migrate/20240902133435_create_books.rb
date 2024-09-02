class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.text :title
      t.text :author
      t.text :genre
      t.text :summary
      t.text :short_summary
      t.integer :publication_year
      t.text :cover_image_url

      t.timestamps
    end
  end
end
