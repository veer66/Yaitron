import sys
import sqlite3
from yaitron_reader import YaitronReader 
import json

reload(sys)

sys.setdefaultencoding('utf8')
reader = YaitronReader("../data/yaitron.xml")

for entry in reader.read():
  print(json.dumps(entry.to_dict()))
