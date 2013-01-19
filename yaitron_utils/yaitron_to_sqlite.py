import sys
import sqlite3
from yaitron_reader import YaitronReader 

reload(sys)        
sys.setdefaultencoding('utf8')        

reader = YaitronReader("../data/yaitron.xml")
conn = sqlite3.connect("yaitron.sqlite")

c = conn.cursor()

# c.execute('drop table entry');
# c.execute('drop table translation');
c.execute("""create table entry(
  _id integer primary key,
  lang text,
  headword text,
  pos text,
  examples text,
  classifier text,
  definitions text,
  notes text,
  synonyms text,
  antonyms text);""")

c.execute("""create table translation(
  _id integer primary key,
  lang text,
  body text,
  exact boolean,
  entry_id integer);""")

def convert_list(lst):
  if len(lst) == 0:
    return None
  else:
    return ";".join(lst)

entry_id = 1
translation_id = 1
for entry in reader.read():
  entry_tuple = (entry_id, entry.lang, entry.headword, entry.pos, convert_list(entry.examples),
    convert_list(entry.classifiers), convert_list(entry.definitions), convert_list(entry.notes), 
    convert_list(entry.synonyms), convert_list(entry.antonyms))
  #print entry.headword, convert_list(entry.synonyms), entry_id
  c.execute("INSERT INTO entry VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", entry_tuple)
  
  translation = entry.translation
  c.execute("INSERT INTO translation VALUES (?, ?, ?, ?, ?)", 
    (translation_id, translation.lang, translation.text, True, entry_id))
  translation_id += 1
  
  for translation in entry.similar_translations:
    c.execute("INSERT INTO translation VALUES (?, ?, ?, ?, ?)", 
      (translation_id, translation.lang, translation.text, False, entry_id))
    translation_id += 1
  
  entry_id += 1
  conn.commit()
  # print entry_id