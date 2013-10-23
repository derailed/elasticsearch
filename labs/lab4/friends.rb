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
    if con.indices.exists_alias name: User.alias_name
      con.indices.delete_alias index: User.index_at(version),
                               name:  User.alias_name
    end
  end

  def self.create_alias(version)
    con.indices.put_alias name:  User.alias_name,
                          index: User.index_at(version)
  end

  def self.delete_index(version)
    if con.indices.exists index: User.index_at(version)
      con.indices.delete index:  User.index_at(version)
    end
  end

  def self.create_index(version)
    delete_index(version)

    con.indices.create index: User.index_at(version),
                       type:  User.doc_type,
                       body:  { mappings: { User.doc_type => User.mappings } }

    User.includes(friends:[:user,:friend]).find_in_batches do |group|
      con.bulk body: group.map{ |doc|
         flat = doc.flatten
         { index: {
            _index: User.index_at(version),
            _type:  User.doc_type,
            _id:    flat.delete(:id),
            data:   flat
         }}}
      puts "Inserted #{con.count index: User.index_at(version)} documents"
    end
  end

  def self.countries
    res = Map(con.search index:  User.alias_name,
                         type:   User.doc_type,
                         size:   0,
                         body:  {
                           query:  {match_all:{}},
                           facets: {
                             countries: {
                               terms: {field:"country", size:10}}}})

    res.facets.countries.terms.each do |t|
      puts "#{t.term}(#{t['count']})"
    end
  end


  def self.popular
    res = Map(con.search index:  User.alias_name,
                         type:   User.doc_type,
                         size:   0,
                         body:  {
                           query:  {match_all:{}},
                           facets: {
                             popular: {
                               terms: {field:"friends.name", size:10}}}})

    res.facets.popular.terms.each do |t|
      puts "#{t.term}(#{t['count']})"
    end
  end

  private

  def self.con
    @con ||= begin
      Elasticsearch::Client.new host:"localhost:9200", trace:true
    end
  end
end
