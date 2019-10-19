import sys
from imp import reload
from yaitron_reader import YaitronReader 
reload(sys)        
  
reader = YaitronReader(sys.argv[1])

for entry in reader.read():
    e = entry.to_dict()
    if e["lang"] == u"th":
        print(e["headword"])
