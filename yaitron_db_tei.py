from xml.dom import pulldom
from simplejson import dumps
import bsddb
import pickle
from xml.dom.minidom import parse, parseString
from Cheetah.Template import Template
import sys


class NoPosError(RuntimeError):
    pass

def get_headword(node):
    headword_nodes = node.getElementsByTagName("headword")
    assert len(headword_nodes) == 1
    headword_node0 = headword_nodes[0]
    headword = headword_node0.firstChild.nodeValue
    return headword

def get_examples(node):
    example_nodes = node.getElementsByTagName("example")
    return [node.firstChild.nodeValue for node in example_nodes]

def get_simple_list(node, tag):
    example_nodes = node.getElementsByTagName(tag)
    return [node.firstChild.nodeValue for node in example_nodes]

def get_definitions(node):
    return get_simple_list(node, "definition")

def get_classifiers(node):
    return get_simple_list(node, "classifier")
    
def get_pos(node):
    pos_nodes = node.getElementsByTagName("pos")
    if len(pos_nodes) == 0:
        raise NoPosError
    assert len(pos_nodes) <= 1
    if len(pos_nodes) < 1:
        return None
    else:
        pos_node0 = pos_nodes[0]
        return pos_node0.firstChild.nodeValue

class Translation:
    def __init__(self, text, lang):
        self.text = text
        self.lang = lang[0:2]

def get_translation(node):
    translation_nodes = node.getElementsByTagName("translation")
    assert len(translation_nodes) == 1
    translation_node0 = translation_nodes[0]
    lang = translation_node0.getAttribute("lang") 
    text = translation_node0.firstChild.nodeValue
    return Translation(text, lang) 

def get_similar_translations(node):
    def get_each_tr(child):
        lang = child.getAttribute("lang") 
        text = child.firstChild.nodeValue
        return Translation(text, lang) 
    nodes = node.getElementsByTagName("translation")
    return [get_each_tr(node) for node in nodes]  


def create_entry(node):
#    lang = node.getAttribute("lang")
#    headword = get_headword(node)
#    pos = get_pos(node)
#    translation, trans_lang = get_translation(node)
#    
#    entry = {"headword": headword,
#             "lang": lang,
#             "pos": pos,
#             "translation": {"lang": lang, "text": translation}}      
    return Entry(node)


def get_notes(node):
    return get_simple_list(node, "note")

def get_synonyms(node):
    return get_simple_list(node, "synonym")
    
def get_antonyms(node):
    return get_simple_list(node, "antonym")
    
class Entry:
    def __init__(self, node):
        self.lang = node.getAttribute("lang")[0:2]
        self.headword = get_headword(node)
        self.pos = get_pos(node).lower()
        self.translation = get_translation(node)
        self.examples = get_examples(node)
        self.classifiers = get_classifiers(node)
        self.similar_translations = get_similar_translations(node)
        self.definitions = get_definitions(node)
        self.notes = get_notes(node)
        self.synonyms = get_synonyms(node)
        self.antonyms = get_antonyms(node)
        
class DictDb:
    def __init__(self):
        self.db = bsddb.hashopen("yaitron.db", "r")

    def __iter__(self):
        i = 0
        for key in self.db:
            i += 1
#            if i > 1000:
#                break
            raw_entry = self.db[key]
            doc = parseString(u"<doc>" + raw_entry + u"</doc>")
            print >>sys.stderr, "i = ", i
            print >>sys.stderr, raw_entry
            try:
                entry = create_entry(doc.getElementsByTagName("entry")[0])
                yield entry
            except NoPosError, e:
                pass

    def close(self):
        self.db.close()
        

def main():
    import sys  
    reload(sys)  
    sys.setdefaultencoding('utf-8')

    t = Template(file=open("teitmpl.xml"))

    dict_db = DictDb()
    t.dictionary = dict_db
    
    print t


    dict_db.close()
          
if __name__ == '__main__':
    main()
