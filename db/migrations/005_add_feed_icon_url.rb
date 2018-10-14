Sequel.migration do
  change do
    alter_table :source_feeds do
      add_column :icon_url, String
    end
  end
end