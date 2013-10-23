require 'active_record'

# Isolating model classes...
class User < ActiveRecord::Base
  has_many :friends, class_name: 'Friendship', foreign_key: :user_id

  def self.index_at(version) "users_v#{version}" end
  def self.alias_name;       :users              end
  def self.doc_type;         :user               end

  def flatten
    {
      id:      id,
      name:    username,
      bio:     self.Biography,
      country: self.Country,
      company: self.CompanyName,
      friends: friends.map{|f| {id:f.friend.id, name:f.friend.username} }
    }
  end

  def self.mappings
    @mapping ||= begin
      {
        _source:    { enable:true, compressed:true },
        properties: {
          id:       { type: :integer, index:    :not_analyzed },
          name:     { type: :string , index:    :not_analyzed },
          country:  { type: :string , index:    :not_analyzed, null_value: "N/A" },
          company:  { type: :string , index:    :not_analyzed },
          bio:      { type: :string , analyzer: :snowball },
          friends:  {
            properties: {
              id:   { type: :integer, index:    :not_analyzed },
              name: { type: :string , analyzer: :snowball }
            }
          }
        }
      }
    end
  end
end

class Friendship < ActiveRecord::Base
  belongs_to :user  , class_name: User, foreign_key: :user_id
  belongs_to :friend, class_name: User, foreign_key: :friend_id
end
