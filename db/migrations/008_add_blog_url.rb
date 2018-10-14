Sequel.migration do
  change do
    alter_table :source_feeds do
      add_column :blog_url, String
    end
  end
end