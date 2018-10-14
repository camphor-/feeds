Sequel.migration do
  change do
    alter_table :source_feeds do
      add_column :title, String
    end
  end
end