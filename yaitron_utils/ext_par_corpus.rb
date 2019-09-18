# coding: utf-8
require 'json'

def th(e)
  headword = e["headword"]
  e["translation"]["text"].gsub(/\([^\)]+\)/, '').split(/\//).each do |sub_tr|
    sub_tr = sub_tr.strip
    puts "#{sub_tr}\t#{headword}"
  end
end

def en(e)
  headword = e["headword"]
  e["translation"]["text"].split(";").each do |tr|
    tr = tr.strip
    next if tr =~ /^กริยาช่อง/
    tr = tr.gsub(/\([^\)]+\)/, '')
    tr.split(/[\/,]/).each do |sub_tr|      
      sub_tr = sub_tr.gsub(/\t/, ' ').strip
      puts "#{headword}\t#{sub_tr}"
    end
  end
end

path = '../data/yaitron.ndjson'

File.open(path, 'r').each_line do |line|
  e = JSON.parse(line)
  th(e) if e["lang"] == "th"
  en(e) if e["lang"] == "en"
end
