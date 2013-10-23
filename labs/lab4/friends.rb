require File.join( File.dirname(__FILE__), 'models.rb' )
require 'elasticsearch'
require 'active_support'
require 'map'

class Friends
  def self.environment
    #ActiveRecord::Base.logger = Logger.new(STDERR)
    ActiveRecord::Base.establish_connection(
      adapter:  'mysql2',
      database: 'cafewell_development'
    )
  end

  def self.move_alias( from, to )
    delete_alias( from )
    create_alias( to )
  end

  def self.delete_alias(version)
  end

  def self.create_alias(version)
  end

  def self.delete_index(version)
  end

  def self.create_index(version)
    delete_index(version)

    User.includes(friends:[:user,:friend]).find_in_batches do |group|
    end
  end

  def self.countries
  end


  def self.popular
  end

  private

  def self.con
    @con ||= begin
      Elasticsearch::Client.new host:"localhost:9200", trace:true
    end
  end
end
