import sys
from yaitron_reader import YaitronReader 
reload(sys)        
sys.setdefaultencoding('utf-8')   
reader = YaitronReader(sys.argv[1])

for entry in reader.read():
    e = entry.to_dict()
    if e["lang"] == u"th":
        print e["headword"]
