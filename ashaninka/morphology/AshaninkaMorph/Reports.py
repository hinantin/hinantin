#!/usr/bin/python

import sys, getopt
import datetime
import mysql.connector
import ConfigParser

# =========================================================
# This file connects to the Lexical Database prototype and 
# produces a report in the form of a lexicon which will be 
# directly compiled by the FOMA Toolkit or XFST. 
# =========================================================

# python Reports.py --file=nroot.prq.foma --header=NRootPRQin --headershort=NRoot --lang=4 --type=12
def main(argv):
   File = 'nroot.prq.foma'
   FileHeader = 'NRootPRQin'
   FileHeaderShort = 'NRoot'
   Language = 4
   Type = 12
   try:
      opts, args = getopt.getopt(argv,"hf:e:s:l:t:",["file=","header=","headershort=","lang=","type="])
   except getopt.GetoptError:
      print 'Reports.py -f <file> -e <fileheader> -s <fileheadershort> -l <language> -t <type>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'Reports.py -f <file> -e <fileheader> -s <fileheadershort> -l <language> -t <type>'
         sys.exit()
      elif opt in ("-f", "--file"):
         File = arg
      elif opt in ("-e", "--header"):
         FileHeader = arg
      elif opt in ("-s", "--headershort"):
         FileHeaderShort = arg
      elif opt in ("-l", "--lang"):
         Language = arg
      elif opt in ("-t", "--type"):
         Type = arg
   config = ConfigParser.RawConfigParser()
   config.read('ConfigFile.ini')
   SECTION = 'DEVELOPMENT'
   HOST = config.get(SECTION, 'HOST')
   USER = config.get(SECTION, 'USER')
   PASSWORD = config.get(SECTION, 'PASSWORD')
   DATABASE = config.get(SECTION, 'DATABASE')

   cnx = mysql.connector.connect(user=USER, database=DATABASE, host=HOST, password=PASSWORD)
   cursor = cnx.cursor()

   query = ("CALL sp_Report_Entry4MorfAnalysis( '"+FileHeaderShort+"' , "+str(Language)+" , "+str(Type)+" ) ;")
   cursor.execute(query)

   # Opening the file
   fo = open(File, "wb")
   index = 0;
   fo.write("define "+FileHeader+" [\n")
   for lexicon_entry in cursor.fetchall():
     #print lexicon_entry
     if index==0:
       x=lexicon_entry[0] 
       fo.write(" "+x[1:]+"\n")
     else:
       fo.write(lexicon_entry[0]+"\n") 
     index+=1
   fo.write("];\n")
   # Closing the file
   fo.close()

   cursor.close()
   cnx.close()

if __name__ == "__main__":
   main(sys.argv[1:])
