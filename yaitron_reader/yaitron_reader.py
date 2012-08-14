from xml.dom import pulldom
import sys

class NoPosError(RuntimeError):
    pass

class Translation:
    def __init__(self, text, lang):
        self.text = text
        self.lang = lang[0:2]

class Entry:
    def __init__(self, node):
        self.lang = node.getAttribute("lang")[0:2]
        self.headword = self.get_headword(node)
        self.pos = self.get_pos(node).lower()
        self.translation = self.get_translation(node)
        self.examples = self.get_examples(node)
        self.classifiers = self.get_classifiers(node)
        self.similar_translations = self.get_similar_translations(node)
        self.definitions = self.get_definitions(node)
        self.notes = self.get_notes(node)
        self.synonyms = self.get_synonyms(node)
        self.antonyms = self.get_antonyms(node)

    def get_headword(self, node):
        headword_nodes = node.getElementsByTagName("headword")
        assert len(headword_nodes) == 1
        headword_node0 = headword_nodes[0]
        headword = headword_node0.firstChild.nodeValue
        return headword

    def get_examples(self, node):
        example_nodes = node.getElementsByTagName("example")
        return [node.firstChild.nodeValue for node in example_nodes]

    def get_simple_list(self, node, tag):
        example_nodes = node.getElementsByTagName(tag)
        return [node.firstChild.nodeValue for node in example_nodes]

    def get_definitions(self, node):
        return self.get_simple_list(node, "definition")

    def get_classifiers(self, node):
        return self.get_simple_list(node, "classifier")

    def get_pos(self, node):
        pos_nodes = node.getElementsByTagName("pos")
        if len(pos_nodes) == 0:
            raise NoPosError
        assert len(pos_nodes) <= 1
        if len(pos_nodes) < 1:
            return None
        else:
            pos_node0 = pos_nodes[0]
            return pos_node0.firstChild.nodeValue

    def get_translation(self, node):
        translation_nodes = node.getElementsByTagName("translation")
        assert len(translation_nodes) == 1
        translation_node0 = translation_nodes[0]
        lang = translation_node0.getAttribute("lang") 
        text = translation_node0.firstChild.nodeValue
        return Translation(text, lang) 

    def get_similar_translations(self, node):
        def get_each_tr(child):
            lang = child.getAttribute("lang") 
            text = child.firstChild.nodeValue
            return Translation(text, lang) 
        nodes = node.getElementsByTagName("translation-similar")
        return [get_each_tr(node) for node in nodes]  
    
    def get_notes(self, node):
        return self.get_simple_list(node, "note")

    def get_synonyms(self, node):
        return self.get_simple_list(node, "synonym")

    def get_antonyms(self, node):
        return self.get_simple_list(node, "antonym")

class YaitronReader:
    def __init__(self, filename):
        self.filename = filename
        
        
    def read(self):
        events = pulldom.parse(self.filename)
        events = pulldom.parse(sys.argv[1])
        for (event, node) in events:
            if event == "START_ELEMENT" and node.tagName == "entry":
                events.expandNode(node)
                entry = Entry(node)
                yield entry
        
def main():
    import sys  
    reload(sys)  
    sys.setdefaultencoding('utf-8')   
    reader = YaitronReader(sys.argv[1])
    for entry in reader.read():
        print(entry.lang, entry.translation.text)
          
if __name__ == '__main__':
    main()
