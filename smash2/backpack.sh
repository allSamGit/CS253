#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   autograder.sh -- Grades the smash2 project awarding partial credit
#
# SYNOPSIS
#   backpack.sh outputFile
#
# DESCRIPTION
#   This script grades the CS253 "smash" Part2 project, awarding partial
#   credit.  The script keeps a running total of a student's score, and, after
#   a problem is encountered, attempts to grade whatever else might work.  
#
#   The script records feedback to the student in the specified file in a
#   format that can also be processed by the "backpack -g" auto-grader command
#   (which requires the file be named rubric.txt).
#
#   Most messages written by the script include the line-number of their origin:
#     [42] Foo Fi Fo Fum I smell the blood of an Englishman
#   in brackets, [42].  If you open the script in an editor, you can examine
#   around the line of their origin to investigate what is happening there.
#
# RESOURCES
#   test.in         Regression test of Smash Part1 functionality
#   test.out        Expected output from test.in
#   basicHistory.in Test data for the history command
#
# HISTORY
#   03/08/2018 Epoch..........................................................jrc
#--------------------------------------------------------------------------------
if [ "$1" = "" ]; then
  echo "usage: $0 outputfile"
  exit 0;
fi

#Initialize variables used in this instance of the grading script
dest="$1"
score=0
tmpFile=/tmp/jrc"$$"
EXE=smash
testIn="test.in"
testOut="test.out"


#Note... this temp file is used to capture errors/warnings from certain commands
errMsg=ErrorsAndWarnings.txt

#clean up any old junk from previous builds
rm -f expected actual *.o $EXE $dest $errMsg


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
#Note:  The error/warning messages in $tmpFile are later overwritten
logMsg $LINENO "Note:  Grading the build"
make 2>$tmpFile
if [ "$?" == 0 ]; then
  awardnGrep $LINENO error   $tmpFile 4
  awardnGrep $LINENO warning $tmpFile 4
  DPRINT $LINENO: $score
else
    logMsg $LINENO "FATAL:  make failed.  Grading ends."
    echo "Grade: 0 points" >>$dest
    exit 
fi


#Make sure the program built with the expected name
awardFileExists $LINENO $EXE 1
DPRINT $LINENO: $score



#Verify program will run given no input whatsoever beyond EOF--------------------
logMsg $LINENO "Note:  Grading smash exits normally with EOF input"
timeout 5s ./$EXE </dev/null >>$errMsg 2>>$errMsg
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: $EXE ran and exited normally after EOF for 1 points"
  score=$[ score + 1 ]
else
  logMsg $LINENO "ERROR: $EXE exited abnormally or hung after EOF"
fi
DPRINT $LINENO: $score



#Verify smash still supports the exit command-------------------------------------
logMsg $LINENO "Note:  Grading the exit command"
echo exit | timeout 5s ./$EXE 2>>$errMsg
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: exit command exited normally for 2 points"
  score=$[ score + 2 ]
else
  logMsg $LINENO "ERROR: exit command timed-out or exited with non-zero status"
fi
DPRINT $LINENO: $score



#Verify smash can still change to user's home directory----------------------------
logMsg $LINENO "Note:  Grading the cd command"
echo "cd $HOME"   >jrc1
result=$( timeout 5s ./$EXE <jrc1 2>>$errMsg)
if [ "$result" == "$HOME" ]; then
    logMsg $LINENO "SCORE:  cd $HOME succeeded for 2 points"
    score=$[ score + 2 ]
else
    logMsg $LINENO "ERROR:  Did not change directories correctly"
    logMsg $LINENO "Expected: $HOME, Your Output: $result"
fi
DPRINT $LINENO: $score



#Verify smash still emits an error message for cd to a non-existent directory----
logMsg $LINENO "Note:  Grading the cd to a non-existent directory"
echo "cd no-such-directory"   >jrc2
timeout 5s ./$EXE <jrc2 >$tmpFile 2>&1
awardGrep $LINENO "Error" $tmpFile 1
DPRINT $LINENO: $score



#Verify smash still parses tokens per the assignment-----------------------------
timeout 5s ./$EXE <$testIn >$tmpFile 2>>$errMsg
diff $testOut $tmpFile >>diff.out
if [ "$?" == 0 ];then
    logMsg $LINENO "SCORE:  tokens parsed correctly for 1 points"
    score=$[ score + 1 ]
    rm diff.out
else
    logMsg $LINENO "ERROR:  smash is not parsing tokens from file $testIn per assignment"
    logMsg $LINENO "Expected output is in $testOut"
    logMsg $LINENO "Actual output is in $tmpFile"
    logMsg $LINENO "Diff result is in diff.out"
fi
DPRINT $LINENO:  $score



#Verify function names required by the assignment appear in the history.c sources
awardGrep $LINENO init_history history.c 1
awardGrep $LINENO add_history  history.c 1
awardGrep $LINENO clear_history history.c 1
awardGrep $LINENO print_history history.c 1



#Verify the basic functionality of the history command
timeout 5s ./$EXE <basicHistory.in >$tmpFile 2>>$errMsg
awardGrep $LINENO "0.*ls"      $tmpFile 4
awardGrep $LINENO "1.*cd"      $tmpFile 4
awardGrep $LINENO "2.*pwd"     $tmpFile 4
awardGrep $LINENO "3.*history" $tmpFile 4
awardGrep $LINENO "4.*history" $tmpFile 4



#Verify that valgrind finds nothing of extreme significance
timeout 5s valgrind ./$EXE <basicHistory.in >$tmpFile 2>&1
awardnGrep $LINENO "Invalid\\s*write"  $tmpFile 4
awardnGrep $LINENO "definitely lost\\s*[1-8]" $tmpFile 4



#Grade make clean-----------------------------------------------------------------
logMsg $LINENO "Note:  Grade make clean"
make clean
awardnFileExists $LINENO smash.o 1
awardnFileExists $LINENO smash   1
DPRINT $LINENO: $score


#Record score
echo "Grade:  $score points" >>$dest
