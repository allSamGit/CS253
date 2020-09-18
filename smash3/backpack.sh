#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   autograder.sh -- Grades the smash3 project awarding partial credit
#
# SYNOPSIS
#   backpack.sh outputFile
#
# DESCRIPTION
#   This script grades the CS253 "smash" Part3 project, awarding partial
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
#   04/01/2018 Epoch..........................................................jrc
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
testDir="testDir"

#The SMASH_KILL environment variable
export SMASH_KILL=1


#Note... this temp file is used to capture errors/warnings from certain commands
errMsg=ErrorsAndWarnings.txt

#clean up any old junk from previous builds
rm -fr expected actual *.o $dest $errMsg $testDir
rm $EXE


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
  awardnGrep $LINENO warning $tmpFile 10
  DPRINT $LINENO: $score
else
    logMsg $LINENO "FATAL:  make failed.  Grading ends."
    echo "Grade: 0 points" >>$dest
    exit 
fi





#Verify smash still supports the exit command-------------------------------------
logMsg $LINENO "Note:  Grading the exit command"
echo exit | timeout 5s ./$EXE 2>>$errMsg
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: exit command exited normally for 5 points"
  score=$[ score + 5 ]
else
  logMsg $LINENO "ERROR: exit command timed-out or exited with non-zero status"
fi
DPRINT $LINENO: $score



#Verify smash can execute commands with arguments and truly cd into a directory
logMsg $LINENO "Note:  Grading commands, arguments and the cd command"
#Build a test file in a test directory
mkdir $testDir
echo TESTDATA >$testDir/testFile.txt
#Verify that smash can execute cmds to cd into test directory and delete the test file
echo "cd $testDir"          >jrc1
echo "rm -f testFile.txt"  >>jrc1
timeout 5s ./$EXE <jrc1 2>>$errMsg
awardnFileExists $LINENO testDir/testFile.txt 10
DPRINT $LINENO: $score
#Cleanup
rm -fr $testDir jrc1




#Verify "command not found" error message from an attempt to execute non-existent pgm
logMsg $LINENO "Note:  Grading attempt to execute a non-existent command/pgm"
echo nonExistentCommandName >jrc1
timeout 5s ./$EXE <jrc1 >$tmpFile 2>&1
awardGrep $LINENO "not *found" $tmpFile 12



#Verify the basic functionality of the history command
timeout 5s ./$EXE <basicHistory.in >$tmpFile 2>>$errMsg
awardGrep $LINENO "ls"      $tmpFile 2
awardGrep $LINENO "cd"      $tmpFile 2
awardGrep $LINENO "pwd"     $tmpFile 2
awardGrep $LINENO "history" $tmpFile 2



#Hunt for zombies
timeout 5s ./$EXE <zombieCheck.in >$tmpFile 2>>$errMsg
awardnGrep $LINENO "defunct" $tmpFile 10




#Verify that valgrind finds nothing of extreme significance
timeout 5s valgrind ./$EXE <basicHistory.in >$tmpFile 2>&1
awardnGrep $LINENO "Invalid\\s*write"  $tmpFile 10
awardnGrep $LINENO "definitely lost\\s*[1-8]" $tmpFile 10



#Cleanup
#make clean
#rm -f jrc1 jrc2
#DPRINT $LINENO: $score


#Record score
echo "Grade:  $score points" >>$dest
