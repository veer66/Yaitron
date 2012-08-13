# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
# 
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
# 
# The Original Code is YAiTRON code.
# 
# The Initial Developer of the Original Code is Vee Satayamas.
# Portions created by Vee Satayamas are Copyright (C) 2006
# All Rights Reserved.
# 
# Contributor(s):

require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'
require 'rexml/element'
class YaitronMaker
	def initialize
	end
	
	def entryToTxt(entry)
		txt = ""
		entry.each{|k,v|
			txt += "#{k}: "
			v.each{|e|
				txt += "[" + e + "]"
			}
			txt += "\n"
		}
		return txt
	end
	
 	
	def addSimple(oldEntry, key, newEntry, target, attrs = nil, optional = true)
		if oldEntry.has_key?(key)
			oldEntry[key].each{|txt|
				element = REXML::Element.new(target)
				if attrs != nil
					attrs.each{|k,v| 
						element.add_attribute(k, v)
					}
				end
				element.add_text(txt)
				newEntry << element
			}			
		else
			if not optional
				raise "No required key"
			end
		end
	end 
	def header
		print "<YAiTRON>\n"
		print "<!-- YAiTRON is a homogeneous structure dictionary. YAiTRON is created by the adaptation of LEXiTRON developed by NECTEC (http://www.nectec.or.th/) -->\n"
	end
	
	def footer
		print "</YAiTRON>\n"
	end
	
	def splitSense(headword, searchTxtArray, eStyle)
		result = Struct.new(:headword, :sense)
		if not searchTxtArray.include?(headword)
			a = headword.split
			if /^\d+$/ === a.last 
				return result.new(a[0..-2].join(" "), a.last)
			elsif eStyle and /^(\w+)(\d+)$/ === headword
                return result.new($1.clone, $2.clone)
            end
		end       
		return result.new(headword, nil)
	end
	
	def addHeadwordsAndSense(entry, newEntry, searchKey, 
                             headwordKey, eStyle=false)
		if not entry.has_key?(headwordKey)
			raise "Headword is required"
		else
			if entry[headwordKey].length != 1
				raise "Invalid headword number"
			end
			headword = entry[headwordKey].first
		end
		if entry.has_key?(searchKey)
			searchTxtArray = entry[searchKey]
		else
			searchTxtArray = []
		end
		result = splitSense(headword, searchTxtArray, eStyle)
		headword = result.headword
		sense = result.sense
		
		# headword
		headwordElement = REXML::Element.new('headword')
		headwordElement.add_text(headword)
		newEntry << headwordElement
	
		# sense
		if sense != nil
			senseElement = REXML::Element.new('sense')
			senseElement.add_attribute('level', 1)
			senseElement.add_text(sense)
			newEntry << senseElement
		end
		
		# headword-var				
		searchTxtArray.each{|txt|
			if txt != headword
				headwordVarElement = REXML::Element.new('headword-var')
				headwordVarElement.add_text(txt)
				newEntry << headwordVarElement
			end
		} 
		
	end

	def addLexitronId(entry, newEntry)
		lexitronIdElement = REXML::Element.new('lexitron')
		lexitronIdElement.add_attribute('id', entry['id'])
		newEntry << lexitronIdElement
	end
	
	def addEntry(entry, lang)
		newEntry = REXML::Element.new('entry')
		newEntry.add_attribute('lang', lang)
		case lang
		when 'tha'
			addSimple(entry, 'tnum', newEntry, 'classifier') #1
			addSimple(entry, 'tcat', newEntry, 'pos') #2
			addSimple(entry, 'eentry', newEntry, 'translation', {'lang'=>'eng'}) #3
			addSimple(entry, 'tenglish', newEntry, 'translation-similar', {'lang'=>'eng'}) #4
			addSimple(entry, 'tdef', newEntry, 'definition') #5
			addSimple(entry, 'notes', newEntry, 'note') #6
			addHeadwordsAndSense(entry, newEntry, 'tsearch', 'tentry') #7 8 9
			addSimple(entry, 'tsyn', newEntry, 'synonym') #10
			addSimple(entry, 'tant', newEntry, 'antonym') #11
			addSimple(entry, 'tsample', newEntry, 'example') #12
			addLexitronId(entry, newEntry) #13			
		when 'eng'
			addSimple(entry, 'ecat', newEntry, 'pos') #1		
			addHeadwordsAndSense(entry, newEntry, 'esearch', 'eentry', true) #2 3 4
			addSimple(entry, 'esyn', newEntry, 'synonym') #5
			addSimple(entry, 'tentry', newEntry, 'translation', {'lang'=>'tha'}) #6
			addSimple(entry, 'ethai', newEntry, 'translation-similar', {'lang'=>'tha'}) #7
			addSimple(entry, 'eant', newEntry, 'antonym') #8
			addSimple(entry, 'esample', newEntry, 'example') #9
			addLexitronId(entry, newEntry) #10 
			addSimple(entry, 'edef', newEntry, 'definition') #11
			addSimple(entry, 'notes', newEntry, 'note') #12
		else
			raise "No lang"
		end
		print newEntry.to_s(0)
		print "\n"
	end
end

class LexitronListener 
	include REXML::SAX2Listener
	ENTRY_TAG = 'Doc'
	def initialize(yaitronMaker)
		@yaitronMaker = yaitronMaker
		@stack = []
		@entry = nil
		@txt = nil
	end
	
	def start_element(uri, localname, qname, attributes)
		@stack.push(qname)
		if @stack.last == 'Doc'
			@entry = Hash.new
		end
		
	end
	
	def end_element(uri, localname, qname)
		if @stack.last == 'Doc'
			@yaitronMaker.addEntry(@entry, @lang)
		end
		@stack.pop
		if @stack.last == 'Doc'
			if not @entry.has_key?(qname)
				@entry[qname] = []
			end
			@entry[qname] << @txt
		end
	end
	
	def characters(text)
		@txt = text
	end
	
end

class TeLexitronListener < LexitronListener
	def initialize(yaitronMaker)
		super(yaitronMaker)
		@lang = 'tha'
		
	end
end

class EtLexitronListener < LexitronListener

	def initialize(yaitronMaker)
		super(yaitronMaker)
		@lang = 'eng'
	end
end


if $0 == __FILE__
	yaitronMaker = YaitronMaker.new	
	yaitronMaker.header
	
	etLexitronParser = REXML::Parsers::SAX2Parser.new(
		REXML::SourceFactory.create_from(File.new("e.xml", "r")))
	etLexitronParser.listen(EtLexitronListener.new(yaitronMaker))
	
	teLexitronParser = REXML::Parsers::SAX2Parser.new(
		REXML::SourceFactory.create_from(open("t.xml", "r")))
	teLexitronParser.listen(TeLexitronListener.new(yaitronMaker))
	
	teLexitronParser.parse
	etLexitronParser.parse
	
	yaitronMaker.footer
end
