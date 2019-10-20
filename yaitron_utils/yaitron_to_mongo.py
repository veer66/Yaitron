import sys
from yaitron_reader import YaitronReader 
from pymongo import Connection
from imp import reload

reload(sys)        
  
reader = YaitronReader(sys.argv[1])

client = Connection()
db = client['yaitron']
enth_dict = db["enth_dict"]

for entry in reader.read():
    row = entry.to_dict()
    enth_dict.insert(row)
