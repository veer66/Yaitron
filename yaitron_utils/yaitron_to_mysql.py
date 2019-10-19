import MySQLdb as Db
import ConfigParser
import sys
from imp import reload
from yaitron_reader import YaitronReader 


class YaitronMysqlExporter:
    def __init__(self):
        config = ConfigParser.ConfigParser()
        config.read("yaitron.cfg")
        self.connection = Db.connect (host = config.get('mysql', 'host'),
                                user = config.get('mysql', 'user'),
                                passwd = config.get('mysql', 'password'),
                                db = config.get('mysql', 'database'),
                                use_unicode=True, 
                                charset="UTF8")
        self.cursor = self.connection.cursor()
        self.li_table_name = config.get('schema', 'li_table')
        self.gloss_table_name = config.get('schema', 'gloss_table')
        self.source_language = config.get('language', "source")
        self.target_language = config.get('language', "target")
                                
    def export(self, filename):
        reader = YaitronReader(filename)
        for entry in reader.read():
            if entry.lang == self.source_language and entry.translation.lang == self.target_language:
                self.put_li(entry)
                li_id = self.get_li_id(entry)
                self.put_gloss(entry.translation.text, li_id)

    def escape(s):
        return self.connection.escape_string(s)

    def put_li(self, entry):                
        if not self.cursor.execute(
                "SELECT id FROM `" + self.li_table_name + "` WHERE `LI` = %s and `pos` = %s", 
                (entry.headword, entry.pos)):
            self.cursor.execute("INSERT INTO `" + self.li_table_name + "`(`LI`, `pos`) VALUES(%s, %s)", 
                ((entry.headword, entry.pos)))
            self.connection.commit()
        
    def get_li_id(self, entry):
        id = None
        if self.cursor.execute(
                "SELECT id FROM `" + self.li_table_name + "` WHERE `LI` = %s and `pos` = %s", 
                (entry.headword, entry.pos)):
            id = self.cursor.fetchone()[0]
        return id
        
    def put_gloss(self, gloss, li_id):
        self.cursor.execute("INSERT INTO `" + self.gloss_table_name + "`(`li_ID`, `gloss`) VALUES(%s, %s)", 
            (str(li_id), gloss))
        self.connection.commit()

reload(sys)        
       
exporter = YaitronMysqlExporter()
exporter.export(sys.argv[1])
