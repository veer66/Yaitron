import sys
import sqlite3
from yaitron_reader import YaitronReader 
import json
from imp import reload

reload(sys)        
       

reader = YaitronReader("../data/yaitron.xml")

eng_dict = {}

for entry in reader.read():
  if entry.lang == 'en':
    if entry.headword not in eng_dict:
      eng_dict[entry.headword] = []
    eng_dict[entry.headword].append(entry.pos)

for k in eng_dict:
  eng_dict[k] = list(set(eng_dict[k]))

print(json.dumps(eng_dict))
