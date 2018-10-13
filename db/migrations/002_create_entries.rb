Sequel.migration do
  change do
    create_table :entries do
      primary_key :entry_id
      foreign_key :source_feed_id, :source_feeds, null: false
      String :entry_url, null: false
      String :title, null: false
      String :abstract, null: false
      String :media_url
    end
  end
end