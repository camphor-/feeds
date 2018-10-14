require 'table'
require 'openssl'

module Icon
  def save_icon(binary_data, file_ext)
    hash_value = OpenSSL::Digest::SHA256.hexdigest(binary_data)
    key = "#{hash_value}.#{file_ext}"

    Table::SourceFeedIcon.insert(key: key, content: Sequel::SQL::Blob.new(binary_data))

    return key
  end
  module_function :save_icon
end