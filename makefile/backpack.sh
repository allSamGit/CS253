#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   backpackpc.sh -- Yet another grading script for the "makefile" project 
#
# SYNOPSIS
#   backpack.sh file
#
# DESCRIPTION
#   The backpackpc.sh grades the CS253 "makefile" project, awarding partial
#   credit.  The script keeps a running total of a student's score, and, after
#   a problem is encountered, attempts to grade whatever else might work.  It
#   tries to follow the advertised grading rubric.
#
#   The script records feedback to the student in the specified file in a
#   format that can also be processed by the "backpack -g" auto-grader command.
#
# HISTORY
#   01/25/2018 Leveraged from 2-tools/projects/makefile/grader/backpack.sh....jrc
#--------------------------------------------------------------------------------
if [ "$1" = "" ];then
  echo "usage: $0 outputfile"
  exit 0;
fi

#Initialize variables used in this instance of the grading script
dest="$1"
score=0
tmpFile=/tmp/jrc"$$"
#echo DEBUG:  $tmpFile

#Clear remains of any previous grading
rm -f *.o myprog main $dest 

#Define a function to award points to score if specified file exists
awardFileExists() {
  if [ -e "$1" ]; then
    score=$[ score + $2 ]
    echo "SCORE:  Found file $1 for $2 points" >>$dest
  else
    echo "ERROR:  File $1 not found" >>$dest
  fi
}

#Define a function to award points to score if files matching a filespec do not exist.
awardNoSuchFile() {
  if ls $1 >/dev/null 2>&1; then
    echo "ERROR:  File $1 should not exist" >>$dest
  else
    score=$[ score + $2 ]
    echo "SCORE:  File $1 removed for $2 points" >>$dest
  fi
}

#Define a function to award points to score if a token can be fgrepped from a specified filespec
awardGrep() {
  output=$(grep "$1" "$2")
  if [ "$?" == 0 ]; then
    score=$[ score + $3 ]
    echo "SCORE:  $1 fgrepped from $2 for $3 points" >>$dest
  else
    echo "ERROR:  Could not fgrep $1 $2" >>$dest
  fi
}

#Makefile compiles all provided files (main.c, f1.c, f2.c f3.c):  2 points each
echo "NOTE:  Grading make" >>$dest
make
awardFileExists main.o 2
awardFileExists f1.o 2
awardFileExists f2.o 2
awardFileExists f3.o 2

#Verify myprog built and will execute with a normal exit status
echo "NOTE:  Grading myprog" >>$dest
awardFileExists myprog 2
output=$(./myprog)
if [ "$?" == 0 ];then
  score=$[ score + 0 ]
  echo "SCORE: myprog executed with normal exit status for 0 points" >>$dest
else        
  echo "ERROR: myprog did not execute and return a 0 status code" >> $dest
fi

#Remake should have nothing to do
echo "NOTE:  Verifying that make does nothing if myprog is up-to-date" >> $dest
make
make >$tmpFile.1
fgrep gcc $tmpFile.1
if [ "$?" == 0 ]; then
  score=$[ score - 5 ]
  echo "ERROR:  Make is rebuilding an up-to-date myprog for -5 points" >>$dest
fi

#Make clean removes all generated files:  5 points
echo "NOTE:  Grading make clean" >>$dest
make clean
awardNoSuchFile "*.o" 3
awardNoSuchFile myprog 2

#Makefile properly detects header file changes:  10 points
echo "NOTE:  Grading header file changes" >>$dest
make
touch *.h
make >$tmpFile.2
fgrep gcc $tmpFile.2
if [ "$?" == 0 ]; then
  score=$[ score + 10 ]
  echo "SCORE:  Makefile rebuilt product following header file change for 10 points" >>$dest
else
  echo "ERROR:  Makefile did not run gcc after the header file touched" >>$dest
fi

#Make myprog builds the executable:  5 points
echo "NOTE:  Grading make myprog" >>$dest
rm -f *.o myprog
make myprog
awardFileExists myprog 5

#Make all builds everything
echo "NOTE:  Grading make all" >>$dest
rm -f *.o myprog
make all
awardFileExists myprog 5

#Makefile uses the macros CC, CFLAGS, $@ and $^ or $<:  15 points
echo "NOTE:  Grading use of macros" >>$dest
awardGrep "CC" Makefile 4
awardGrep "CFLAGS" Makefile 4
awardGrep "\$\@" Makefile 4
awardGrep "[\^\<]" Makefile 3

#Clean up the grading mess and verify clean is using rm -f flag
echo "NOTE:  Grading make clean again" >>$dest
make clean
make clean
if [ "$?" != 0 ]; then
  score=$[ score - 1 ]
  echo "ERROR:  make clean in a clean directory is failing:"  >>$dest
fi

#Fix negative score for missing Makefile
if [ "$score" -lt 0 ]; then
  score=0
fi

#Record the score
echo "NOTE:  Finished grading" >>$dest
echo "Grade:  " $score >>$dest
