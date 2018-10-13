Sequel.migration do
  change do
    create_table :source_feeds do
      primary_key :source_feed_id
      String :feed_url, null: false
    end
  end
end