require 'rubygems'
gem 'mysql'
require 'mysql'
require 'sary'
require 'yaml'

config = YAML.load_file("count_config.yaml")

searcher = Sary::Searcher.new("thaitext.txt")  

db = Mysql.init
db.options(Mysql::SET_CHARSET_NAME, 'utf8')
db.real_connect(config['database']['host'], 
                config['database']['user'], 
                config['database']['password'], 
                config['database']['database'])
db.query("SET NAMES utf8")
db.autocommit(false)

prepared_stmt = db.prepare("UPDATE `" + config['database']['table_name'] + "` SET occurrence_count = ? WHERE id = ?")

db.query("select * from `" + config['database']['table_name'] + "`").each{|row| 
  id = row[0]
  gloss = row[2]
  if searcher.search(gloss)
    count = searcher.count_occurrences
    prepared_stmt.execute(count, id)
    #print "#{id} - #{gloss} - #{count}\n"
    db.commit
  end  
}

prepared_stmt.close
db.close