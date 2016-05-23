import sys
from yaitron_reader import YaitronReader 
reload(sys)        
sys.setdefaultencoding('utf-8')   
reader = YaitronReader(sys.argv[1])

for entry in reader.read():
    e = entry.to_dict()
    if e["lang"] == u"en":
        headword = e["headword"]
        for translation in e["translation"]["text"].split(";"):
            print headword, '|||', translation
    else:
        headword = e["headword"]
        for translation in e["translation"]["text"].split(";"):
            print translation, '|||', headword
