class AddHiddenToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :hidden, :boolean, default: false
  end
end
