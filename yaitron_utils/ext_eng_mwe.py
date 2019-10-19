import sys
from yaitron_reader import YaitronReader 
from imp import reload
reload(sys)        
  
reader = YaitronReader(sys.argv[1])

for entry in reader.read():
    e = entry.to_dict()
    if e["lang"] == u"en":
        headword = e["headword"]
        if len(headword.split()) > 1:
            print(headword)
