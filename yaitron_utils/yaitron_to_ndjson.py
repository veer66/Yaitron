import sys
import sqlite3
from yaitron_reader import YaitronReader 
import json
from imp import reload

reload(sys)


reader = YaitronReader("../data/yaitron.xml")

for entry in reader.read():
  print(json.dumps(entry.to_dict()))
