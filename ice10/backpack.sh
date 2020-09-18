#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   backpack.sh -- Autograder for ice10 exercise
#
# SYNOPSIS
#   backpack.sh outputFile
#
# DESCRIPTION
#   This script grades the ice10 in-class exercise.
#
# HISTORY
#   03/09/2018 Epoch..........................................................jrc
#--------------------------------------------------------------------------------
if [ "$1" = "" ]; then
  echo "usage: $0 outputfile"
  exit 0;
fi

#Initialize variables used in this instance of the grading script
dest="$1"
score=0
tmpFile=/tmp/jrc"$$"
EXE=testStringLength


#Note... this temp file is used to capture errors/warnings from certain commands
errMsg=ErrorsAndWarnings.txt

#clean up any old junk from previous builds
rm -f *.o $dest $EXE $errMsg


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
    logMsg "$1" "ERROR:  grep should not have found \"$2\" in $3"
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


#Build the product and check for errors/warnings (8 points total)-----------------
logMsg $LINENO "Note:  Grading the build"
make 2>$tmpFile
awardnGrep $LINENO warning $tmpFile 1
DPRINT $LINENO: $score


#Run the test program and capture the output
logMsg $LINENO "Executing the test program"
timeout 5s $EXE >$tmpFile 2>>$errMsg

#Verify the output of the test program
logMsg $LINENO "Grading the output of the test program"
awardGrep $LINENO "s1.*3"      $tmpFile 1
awardGrep $LINENO "s2.*1"      $tmpFile 1
awardGrep $LINENO "s4.*0"      $tmpFile 1
awardGrep $LINENO "s5.*0"      $tmpFile 6


#Try to clean up the mess
make clean


#Record score
echo "Grade:  $score points" >>$dest
