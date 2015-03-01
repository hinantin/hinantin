# This example shows how queries can be executed in an iterative manner.
# Iterative evaluation will be slower, as more server requests are performed.
#
# Documentation: http://docs.basex.org/wiki/Clients
#
# (C) BaseX Team 2005-12, BSD License

import sys, getopt
import BaseXClient, time
import ConfigParser
import re
from lxml import etree

def main(argv):
   Type = 'verb'
   try:
      opts, args = getopt.getopt(argv,"ht:",["type="])
   except getopt.GetoptError:
      print 'query_nodes_in_the_transducer_4_foma.py -t <type>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'query_nodes_in_the_transducer_4_foma.py -t <type>'
         sys.exit()
      elif opt in ("-t", "--type"):
         Type = arg

   try:
     # create session
     config = ConfigParser.RawConfigParser()
     config.read('ConfigFile.ini')
     SECTION = 'PRODUCTION'
     HOST = config.get(SECTION, 'HOST')
     USER = config.get(SECTION, 'USER')
     PASSWORD = config.get(SECTION, 'PASSWORD')
     DATABASE = config.get(SECTION, 'DATABASE')
     PORT = int(config.get(SECTION, 'PORT'))
     #session = BaseXClient.Session('localhost', 1984, 'admin', 'admin')
     #databaseFilePath = 'C:\\Users\\Richard\\Documents\\RCastroq\\Dropbox\\05_Ashaninca\\05_Morfologia\\Ashaninka_Morph\\xml\\annotated_sentences_wtg.xml'
     session = BaseXClient.Session(HOST, PORT, USER, PASSWORD)
     databaseFilePath = DATABASE
     fileName = ''
     fileLog = ''
     fileNameSuffixList = ''
     fileNameSuffixListScript = ''
     define = ''
     try:
       # split by ' ' space character the elements product of the query found in the file 
       value = ""
       if Type == 'verb' :
         #value = "PRNO IRR DIR PRF OPT PL REGR CNT.F AUG DUR BEN ADV.P ADV APPR ICPL REL IMP.P quickly EXCL Q APPL noun disheveled.head DIM CL 3m.poss NMZ ADJ once APPL.INT REP poss EMPH APPL.BEN one DEM RCP REV ADJ.n.m. ADJ.m. before ADJ.m ADJ.n.m deceased small.part DEGR small only INCH DIM.DEGR flat early for.a.while not.yet REC"
         fileName = "query_transducer_verb_suffixes_4_python.xq"
         fileLog = "verb.headers.prq.txt"
         fileNameSuffixList = "query_transducer_verb_suffixes_lists.xq"
         fileNameSuffixListScript = "verb.transitions.prq.script"
         define = "define S [\n"
       else:
         #value = "poss DEM PL DIM LOC river CL small.part.DIM ADV EXCL ADV.P AUG monkey deceased leaf NOM EMPH small.part Q DUB ADV.T this wide"
         fileName = "query_transducer_noun_suffixes_4_python.xq"
         fileLog = "noun.headers.prq.txt"
         fileNameSuffixList = "query_transducer_noun_suffixes_lists.xq"
         fileNameSuffixListScript = "noun.transitions.prq.script"
         define = "define N [\n"
       # ************ SUFFIXES TRANSDUCER ************
       input = ''
       with open (fileName, "r") as file:
         input=file.read().replace('\n', ' ')
       query = session.query(input)
       query.bind("$file_name", str(databaseFilePath))
       output = query.execute()
       #print output
       f = open(fileLog,'w')
       f.write(output) # python will convert \n to os.linesep
       f.close() # you can omit in most cases as the destructor will call if
       # #####################################################
       # ************ LIST TRANSDUCER TRANSITIONS ************
       # #####################################################
       input = ''
       with open (fileNameSuffixList, "r") as file:
         input=file.read().replace('\n', ' ')
       query = session.query(input)
       query.bind("$file_name", str(databaseFilePath))
       outputSuffixList = query.execute()
       strList = ''
       # ###################################
       # Deleting empty line (not working)  
       # ###################################
       List = outputSuffixList.split('\n')
       for s in List:
          if s != '':
             if s != " | \n":
                strList = strList + s
       #outputSuffixList = filter(lambda x: not re.match(r'^\s*$', x), outputSuffixList)

       #outputSuffixList = define + outputSuffixList[:-5] + " \n];"
       strList = define + outputSuffixList[:-4] + " \n];"
       f = open(fileNameSuffixListScript,'wb')
       f.write(strList) # python will convert \n to os.linesep
       f.close() # you can omit in most cases as the destructor will call if
       
       values = output
       values = values.split(' ')
       for element in values:
         #print element
         input = (
         "declare variable $node external; "
         "declare variable $type external; "
         "declare variable $file_name external; "
         "fn:distinct-values"
         " ( "
         "  for $word in doc($file_name)//sentences//sentence//words//word "
         #"  where $word[matches(@type,'verb')] "
         #"  where $word[matches(@type,'noun')] "
         "  where $word[matches(@type,$type)] "
         "  for $element in $word//elements//element "
         "  where $element//e_asl[matches(text(),fn:concat('^',$node,'$'))] "
         "  return $element//e_afl//text() "
         " ) "
         )
         query = session.query(input)
         query.bind("$node", str(element))
         query.bind("$type", str(Type))
         query.bind("$file_name", str(databaseFilePath))

         output = query.execute()
         nodeelements = output.split(' ')
         nodeelementsfoma = ''
         for nodeelement in nodeelements:
           nodeelementsfoma += ("{" + nodeelement.lower() + "}|")
         if Type == 'verb' :
           fomafile = "      define V=S=" + element.replace('.', '') + " [\n       \"[--][+" + element + "]\" : \"@EP\"[" + nodeelementsfoma[:-1] + "]\n      ];\n      "
         else:
           fomafile = "      define N=S=" + element.replace('.', '') + " [\n       \"[--][+" + element + "]\" : [" + nodeelementsfoma[:-1] + "]\n      ];\n      "
         print fomafile
       #print values
       # create query instance
       #edges = tree.xpath('/gexf/graph/edges/edge')
       #edges.append(edge)
       #print edges.xpath('count(/edge)')
       #print etree.tostring(edges.getroot())
       #print etree.tostring(tree.getroot())
       # close query object  
       query.close()
     
     except IOError as e:
       # print exception
       print e
       
     # close session
     session.close()
   
   except IOError as e:
     # print exception
     print e

if __name__ == "__main__":
   main(sys.argv[1:])
