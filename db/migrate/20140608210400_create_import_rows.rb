class CreateImportRows < ActiveRecord::Migration
  def change
    create_table :import_rows do |t|
      t.integer :import_id
      t.boolean :import_error

      t.timestamps
    end
  end
end
