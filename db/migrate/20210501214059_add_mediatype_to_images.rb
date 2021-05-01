class AddMediatypeToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :mediatype, :string
  end
end
