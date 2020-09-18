#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   backpack.sh -- autograder for the codeWreck
#
# SYNOPSIS
#   backpack.sh outputFile
#
# DESCRIPTION
#   This script tests the codeWreck application
#
#   Most messages written by the script include the line-number of their origin:
#     [42] Foo Fi Fo Fum I smell the blood of an Englishman
#   in brackets, [42].  If you open the script in an editor, you can examine
#   around the line of their origin to investigate what is happening there.
#
# RESOURCES
#
# HISTORY
#   03/18/2018 Epoch...........................................................CV
#--------------------------------------------------------------------------------
if [ "$1" = "" ]; then
  echo "usage: $0 outputfile"
  exit 0;
fi

#Initialize variables used in this instance of the grading script
dest="$1"
score=0
tmpFile=/tmp/jrc"$$"
EXE=codeWreck


#Additional files for error and warning messages
bldMsg=build.out
errMsg=ErrorsAndWarnings.txt

#clean up any old junk from previous builds
rm -f *.o $EXE $dest $errMsg


#---------------------------------------------------------------------------------
#Define function to log a message to the dest file.
# Usage:  logMsg $LINENO messageText
#---------------------------------------------------------------------------------
logMsg() {
  echo "[$1] " "$2" >>$dest
}

#---------------------------------------------------------------------------------
#Define flags/function for debugging this script.  Use DEBUG=1 to debug.
# Note:  DPRINT writes to stdout
#---------------------------------------------------------------------------------
DEBUG=0
DPRINT() {
  if [ "$DEBUG" == 1 ]; then
    echo "DEBUG:  $@"
  fi
}
DPRINT $tmpFile

#---------------------------------------------------------------------------------
#Define function to award points if pattern will grep from a specified file
# Usage:  awardGrep $LINENO pattern filename nPoints
#---------------------------------------------------------------------------------
awardGrep() {
  output=$(grep -i "$2" "$3")
  if [ "$?" == 0 ]; then
    score=$[ score + $4 ]
    logMsg "$1" "SCORE:  grep found \"$2\" in $3 for $4 points"
  else
    logMsg "$1" "ERROR:  Could not grep \"$2\" in $3 for -$4 points"
  fi
}

#---------------------------------------------------------------------------------
#Define function to award points if pattern CANNOT grep from a specified file
# Usage:  awardnGrep $LINENO pattern filename nPoints
#---------------------------------------------------------------------------------
awardnGrep() {
  output=$(grep -i "$2" "$3")
  if [ "$?" == 1 ]; then
    score=$[ score + $4 ]
    logMsg "$1" "SCORE:  grep confirmed \"$2\" not in $3 for $4 points"
  else
    logMsg "$1" "ERROR:  grep should not find \"$2\" in $3"
  fi
}

#---------------------------------------------------------------------------------
#Define function to award points if the specified file exists
# Usage:  awardFileExists $LINENO filename nPoints
#---------------------------------------------------------------------------------
awardFileExists() {
  if [ -e "$2" ]; then
    score=$[ score + $3 ]
    logMsg "$1" "SCORE:  Found file $2 for $3 points"
  else
    logMsg "$1" "ERROR:  File $2 not found as expected"
  fi
}

#---------------------------------------------------------------------------------
#Define function to award points if the specified file does NOT exist
# Usage:  awardnFileExists $LINENO filename nPoints
#---------------------------------------------------------------------------------
awardnFileExists() {
  if [ -e "$2" ]; then
    logMsg "$1" "ERROR:  File $2 should not exist"
  else
    score=$[ score + $3 ]
    logMsg "$1" "SCORE:  Verified file $2 does not exist for $3 points"
  fi
}



#---------------------------------------------------------------------------------
#NOTE:  Grading begins here
#---------------------------------------------------------------------------------


#Build the product and check for errors/warnings (6 points total)-----------------
logMsg $LINENO "Note:  Grading the build output in $bldMsg"
make 2>$bldMsg
awardnGrep $LINENO error   $bldMsg 2
awardnGrep $LINENO warning $bldMsg 4
DPRINT $LINENO: $score

#Make sure the program built with the expected name
awardFileExists $LINENO $EXE 1
DPRINT $LINENO: $score



#Verify program will run given no input whatsoever beyond EOF--------------------
logMsg $LINENO "Note:  Verify $EXE will exit normally with EOF input"
./$EXE </dev/null >>$errMsg 2>&1
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: $EXE ran and exited normally after EOF for 4 points"
  score=$[ score + 4 ]
else
  logMsg $LINENO "ERROR: $EXE exited abnormally with EOF"
fi
DPRINT $LINENO: $score



#Tests a single VALUE without options
logMsg $LINENO "Testing:   $EXE 1"
./$EXE 1 >$tmpFile 2>>$errMsg
awardGrep $LINENO "1[0\.]\+"  $tmpFile 2


#Tests a single VALUE with -e
logMsg $LINENO "Testing:  $EXE -e 1"
./$EXE -e 1 >$tmpFile 2>>$errMsg
awardnGrep $LINENO "1" $tmpFile 2


#Tests a single VALUE with -o
logMsg $LINENO "Testing:  $EXE -o 1"
./$EXE -o 1 >$tmpFile 2>>$errMsg
awardGrep $LINENO "1[0\.]\+" $tmpFile 2


#Test a complicated command with fractions
logMsg $LINENO "Testing:  $EXE -e 1.0 2.5 3.0 4.0"
./$EXE -e 1.0 2.5 3.0 4.0 >$tmpFile 2>>$errMsg
awardGrep $LINENO "6\.50*" $tmpFile 4






#Verify that valgrind finds nothing of extreme significance
timeout 5s valgrind ./$EXE 1 2 3.5 4 5  >$tmpFile 2>&1
awardnGrep $LINENO "Invalid\\s*"  $tmpFile 4
awardnGrep $LINENO "definitely lost\:\\s*[0-9]" $tmpFile 5



#Cleanup
logMsg $LINENO "Note:  make clean"
make clean
DPRINT $LINENO: $score


#Record score
echo "Grade:  $score points" >>$dest
