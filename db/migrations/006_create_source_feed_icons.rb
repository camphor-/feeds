Sequel.migration do
  change do
    create_table :source_feed_icons do
      String :key, primary_key: true
      bytea :content, null: false
    end
  end
end