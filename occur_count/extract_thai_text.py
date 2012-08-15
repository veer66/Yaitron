import codecs
import re
import sys

for line in codecs.open(sys.argv[1], encoding="UTF8", errors='ignore'):
    for unit in re.split('([\u0E00-\u0EFF]+)', line):
        if re.match('[\u0E00-\u0EFF]+', unit):
            print(unit)