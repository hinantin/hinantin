#Copyright (c) 1999, 2000, 2005 Xerox Corporation.  All Rights Reserved.

default: clean \
../bin/aymara.fst ../bin/aymara-guess.fst ../obj/aymara-common.fst \
../bin/keys.txt  


# aymara.fst is the normal FST, based on roots in the underlying lexicon
aymara.fst: ../bin/aymara.fst

# aymara-guess.fst is the "guessing" FST, used when aymara.fst; aymara-guess.fst
#   recognizes nouns and verbs based on strings that look like canonical Aymara roots
aymara-guess.fst: ../bin/aymara-guess.fst

# first built aymara-common.fst, and then derive aymara.fst and aymara-guess.fst
#   from it
aymara-common.fst: ../obj/aymara-common.fst

keys.txt:  ../bin/keys.txt
aymara-lex.txt: ../obj/aymara-lex.txt
aymara-lex.fst: ../obj/aymara-lex.fst
aymara-rul.fst: ../obj/aymara-rul.fst
aymara-tags.fst: ../obj/aymara-tags.fst


# to make aymara.fst, take aymara-common.fst and just kill all the paths
#   containing NOUNROOTGUESS or VERBROOTGUESS
.PRECIOUS: ../bin/aymara.fst
../bin/aymara.fst:  ../obj/aymara-common.fst
	@echo ""
	@echo "*** Creating aymara.fst ***"
	@echo ""
	@printf "clear stack \n\
		load ../obj/aymara-common.fst \n\
		substitute label NOTHING for NOUNROOTGUESS \n\
		substitute label NOTHING for VERBROOTGUESS \n\
		save stack ../bin/aymara.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp


# to make aymara-guess.fst, take aymara-common.fst and substitute network
#   defined in aymara-roots-possible.script
#   for both NOUNROOTGUESS and VERBROOTGUESS
.PRECIOUS: ../bin/aymara-guess.fst
../bin/aymara-guess.fst:  ../obj/aymara-common.fst \
dic/rootspossible/aymara-possible-roots.script
	@echo ""
	@echo "*** Creating aymara-guess.fst ***"
	@echo ""
	@printf "clear stack \n\
		source dic/rootspossible/aymara-possible-roots.script \n\
		define POSSIBLEROOTS \n\
		clear stack \n\
		load ../obj/aymara-common.fst \n\
		read regex \$$[NOUNROOTGUESS | VERBROOTGUESS] ;\n\
		compose \n\
		substitute defined POSSIBLEROOTS for NOUNROOTGUESS \n\
		substitute defined POSSIBLEROOTS for VERBROOTGUESS \n\
		save stack ../bin/aymara-guess.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp


../obj/aymara-common.fst: ../obj/aymara-tags.fst aymara-clean-upper.script
	@echo ""
	@echo "*** Creating aymara-common.fst ***"
	@echo ""
	@printf "clear stack \n\
		load ../obj/aymara-tags.fst \n\
		source aymara-clean-upper.script \n\
		compose \n\
		save ../obj/aymara-common.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp

../obj/aymara-tags.fst: ../obj/aymara-lex.fst ../obj/aymara-rul.fst
	@echo ""
	@echo "*** Creating aymara-tags.fst ***"
	@echo ""
	@printf "clear stack \n\
		load ../obj/aymara-rul.fst \n\
		load ../obj/aymara-lex.fst \n\
		set flag-is-epsilon ON \n\
		compose \n\
		set flag-is-epsilon OFF \n\
		save stack ../obj/aymara-tags.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp

../obj/aymara-rul.fst: aymara-rul.script
	@echo ""
	@echo "*** Creating aymara-rul.fst ***"
	@echo ""
	@printf "clear stack \n\
		source aymara-rul.script \n\
		save stack ../obj/aymara-rul.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp

../obj/aymara-lex.fst: ../obj/aymara-lex.txt
	@echo ""
	@echo "*** Creating aymara-lex.fst ***"
	@printf "read lexc < ../obj/aymara-lex.txt \n\
		save ../obj/aymara-lex.fst \n\
		quit\n" > /tmp/aymara.tmp
	@xfst -utf8 < /tmp/aymara.tmp
	@rm -f /tmp/aymara.tmp

../obj/aymara-lex.txt: cvtroots cvtsuffs mcs.lexc
	@echo ""
	@echo "*** Creating aymara-lex.txt ***"
	@echo "*** Concatenating various .lexc files ***"
	@echo ""
	cd ../obj; cat mcs.lexc suffs.lexc adjective.lexc dayname.lexc \
digit.lexc interrogative.lexc monthname.lexc multiplier.lexc ncommon.lexc \
negative.lexc nproper.lexc ntemporal.lexc positional.lexc positionaldefective.lexc \
pronoundemonstrative.lexc pronounpersonal.lexc verb.lexc \
nounguess.lexc verbguess.lexc > aymara-lex.txt

cvtroots: lexc_cvtroots.pl dic/roots/roots.xml
	@echo ""
	@echo "*** Converting XML root file to lexc ***"
	@echo ""
	@perl lexc_cvtroots.pl

cvtsuffs: lexc_cvtsuffs.pl
	@echo ""
	@echo "*** Converting XML suffix files to lexc ***"
	@echo ""
	@perl lexc_cvtsuffs.pl

mcs.lexc: ../obj/mcs.list
	@cd ../obj; printf "Multichar_Symbols\n\n" > mcs.lexc
	@cd ../obj; sort mcs.list | uniq >> mcs.lexc

../bin/keys.txt: dic/roots/roots.xml
	@perl extract-key-gloss.pl



clean:
	@echo ""
	@echo "*** Deleting old non-source files ***"
	@cd ../obj; rm -f *
	@cd ../bin; rm -f *.fst *.txt

