#!/bin/bash
#-------------------------------------------------------------------------------
# backpack.sh -- This is the CS253 "setup" project grading script
#
# 01/19/2018 Created from "makefile" project grading script
# 01/20/2018 Award partial credit & record a "Grade:" in output for backpack -e
#
#-------------------------------------------------------------------------------
if [ "$1" = "" ];then
  echo "usage: $0 <output file>"
  echo "   output file - the file to save the grades in"
  exit 0;
fi
dest="$1"
score=0

#Clear the old output file (perhaps we are regrading an assignment)
echo >$dest

#Grade "Install backpack on a lab machine" 25 points if something like hello.c is under management
managedFiles=`git ls-tree -r master --name-only *ello*.c | wc -l`
if [ $managedFiles -gt 0 ]; then
   echo "P1:  Install backpack on a lab machine. 25" >>$dest
   score=$[ score + 25 ]
fi

#Grade "Write hello and push it to the server" 10 points if file exists under a reasonable (even if not exactly correct) name
nHellos=`find . -iname hello*.c -print | wc -l`
if [ $nHellos -gt 0 ]; then
   score=$[ score + 10 ]
   echo "P1:  There might be hello.c.  10" >>$dest
else
   echo "P1:  Failed to push git managed files to the backpack server" >>$dest
fi

#Build the student's assignment
make

#Make sure Makefile built an executable named "hello" (10 additional points)
if [ ! -e "hello" ];then
  echo "P1: Did not build an executable named hello" >> $dest
else
  echo "P1: The Makefile built an executable named hello. 10" >>$dest
  score=$[ score + 10 ]
fi

#Executing "hello" returns 0 status (5 bonus points)
output=$(./hello)
if [ "$?" != 0 ];then
        #We failed
        echo "P1: Executing "hello" did not return 0" >> $dest
else
   echo "P1:  Executing "hello" returns 0 status. (+5 bonus points)" >>$dest
   score=$[ score + 5 ]
fi

#Make sure the clean target works (5 points)
make clean
if [ "$?" != 0 ];then
        #We failed
        echo "P1: make clean returned a non-zero exit (failed)" >> $dest
else
   echo "P1:  make clean returns 0 status.  5" >>$dest
   score=$[ score + 5 ]
fi

#Clean twice to make sure -f flag is used
make clean
echo "P1: Finished grading" >> $dest
echo "Grade:  " $score >>$dest
