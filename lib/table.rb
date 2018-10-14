require 'sequel'
require 'dotenv/load'
require 'openssl'

Sequel::Model.db = Sequel.connect(ENV.fetch("DATABASE_URL"))

module Table
  class SourceFeed < Sequel::Model(:source_feeds)
    one_to_many :entries
    plugin :association_dependencies, entries: :destroy
  end

  class Entry < Sequel::Model(:entries)
    many_to_one :source_feed
  end

  class SourceFeedIcon < Sequel::Model(:source_feed_icons)
    ALLOWED_EXT = %w(.jpg .jpeg .png).freeze
    MAX_SIZE = 5 * 10**6 # 5MB

    # jpgとpngのみ可
    # 5MB以下のファイルのみ可
    # file_extはdotを含む e.g. '.jpg'
    def self.insert_icon(file, file_ext)
      raise ArgumentError, "Invalid icon file type '#{file_ext}'." unless ALLOWED_EXT.include? file_ext
      raise ArgumentError, "Icon file too large. Must be smaller than 5MB." unless file.size <= MAX_SIZE

      binary_data = file.read

      hash_value = OpenSSL::Digest::SHA256.hexdigest(binary_data)
      key = "#{hash_value}#{file_ext}"

      self.dataset.insert_conflict.insert(key: key, content: Sequel::SQL::Blob.new(binary_data))

      return key
    end
  end
end