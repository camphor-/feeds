Sequel.migration do
  change do
    alter_table :entries do
      add_column :published_at, DateTime, null: false
    end
  end
end