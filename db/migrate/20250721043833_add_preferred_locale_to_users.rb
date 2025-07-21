class AddPreferredLocaleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :preferred_locale, :string, default: 'ko'
    add_index :users, :preferred_locale
  end
end
