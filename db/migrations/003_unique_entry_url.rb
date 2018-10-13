Sequel.migration do
  change do
    alter_table :entries do
      add_index :entry_url, unique: true
    end
    alter_table :source_feeds do
      add_index :feed_url, unique: true
    end
  end
end