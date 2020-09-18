#!/bin/bash
#-------------------------------------------------------------------------------
# NAME
#   backpackpc.sh -- Grades the word-count project awarding partial credit
#
# SYNOPSIS
#   backpack.sh file
#
# DESCRIPTION
#   The backpackpc.sh grades the CS253 "word-count" project, awarding partial
#   credit.  The script keeps a running total of a students score, and, after
#   a problem is encountered, attempts to grade whatever else might work.  It
#   tries to follow the advertised grading rubric.
#
#   The script records feedback to the student in the specified file in a
#   format that can also be processed by the "backpack -g" auto-grader command.
#
#   Most messages written by the script include the line-number of their origin:
#     [42] Foo Fo Fi Fum Invalid Englishman found
#   in brackets, [42].  If you open the script in an editor, you can examine
#   around the line of their origin to investigate what is happening there.
#
# HISTORY
#   02/03/2018 Epoch..........................................................jrc
#--------------------------------------------------------------------------------
if [ "$1" = "" ]; then
  echo "usage: $0 outputfile"
  exit 0;
fi

#Initialize variables used in this instance of the grading script
dest="$1"
score=0
tmpFile=/tmp/jrc"$$"
EXE=wc-match

#Note... this temp file is used to capture errors/warnings from certain commands
errMsg=ErrorsAndWarnings.txt

#clean up any old junk from previous builds
rm -f expected actual $dest $errMsg *.result

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
DEBUG=1
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
    logMsg "$1" "SCORE:  grep found $2 in $3 for $4 points"
  else
    logMsg "$1" "ERROR:  Could not grep $2 in $3"
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
    logMsg "$1" "SCORE:  grep confirmed $2 not in $3 for $4 points"
  else
    logMsg "$1" "ERROR:  grep found $2 in $3"
  fi
}

#---------------------------------------------------------------------------------
#Define function to award points if the specified file exists
# Usage:  awardFileExists $LINENO filename nPoints
#---------------------------------------------------------------------------------
awardFileExists() {
  if [ -e "$2" ]; then
    score=$[ score + $2 ]
    logMsg "$1" "SCORE:  Found file $2 for $3 points"
  else
    logMsg "$1" "ERROR:  File $2 not found"
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
    score=$[ score + $2 ]
    logMsg "$1" "SCORE:  Verified file $2 does not exist for $3 points"
  fi
}



#---------------------------------------------------------------------------------
#NOTE:  Grading begins here
#---------------------------------------------------------------------------------

#Build the product and check for errors/warnings (8 points total)----------------
logMsg $LINENO "Note:  Grading the build"
make 2>$tmpFile
awardnGrep $LINENO error   $tmpFile 4
awardnGrep $LINENO warning $tmpFile 4

#Make sure the program built with the expected name
awardFileExists $LINENO $EXE 1



#Verify program will run given no command-line options and no data----------------
logMsg $LINENO "Note:  Grading program will run without options or data"
./$EXE </dev/null >>$errMsg 2>&1
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: $EXE ran and exited normally for 3 points"
  score=$[ score + 3 ]
else
  logMsg $LINENO "ERROR: $EXE did not run/exit normally"
fi



#Verify program will accept the -h option to print the usage message--------------
logMsg $LINENO "Note:  Grading -h option"
./$EXE -h </dev/null >>$errMsg 2>&1
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: $EXE -h exited normally for 5 points"
  score=$[ score + 5 ]
else
  logMsg $LINENO "ERROR: $EXE -h did not exit normally"
fi



#Verify -m exits with non-zero status if the <word> is missing--------------------
logMsg $LINENO "Note:  Grading -m option"
./$EXE -m <data >>$errMsg 2>&1
if [ "$?" == 0 ]; then
  logMsg $LINENO "ERROR: $EXE -m without an argument exit status is 0"
else
  logMsg $LINENO "SCORE: $EXE -m without an argument exit status != 0 for 5 points"
  score=$[ score + 5 ]
fi



#Verify program rejects an invalid option (-x)------------------------------------
logMsg $LINENO "Note:  Grading invalid -x option"
./$EXE -x <data >>$errMsg 2>&1
if [ "$?" == 0 ]; then
  logMsg $LINENO "ERROR: $EXE -x exit status is 0"
else
  logMsg $LINENO "SCORE: $EXE -x exit status != 0 for 1 points"
  score=$[ score + 1 ]
fi



#Run the students program on data------------------------------------------------
logMsg $LINENO "Note:  Grading file, data"
./$EXE -m the <data     >data.result 2>>$errMsg

#Grade word/line/char/digit/matching on data result
awardGrep $LINENO  "words.*5770"   data.result 2
awardGrep $LINENO  "chars.*34553"  data.result 2
awardGrep $LINENO  "lines.*769"    data.result 2
awardGrep $LINENO  "digit.*9.*6"   data.result 2
awardGrep $LINENO  "matched.*545"  data.result 3



#Run and grade the students program on data1-------------------------------------
logMsg $LINENO "Note:  Grading file, data1"
./$EXE -m test <data1   >data1.result 2>>$errMsg

#Grade word/line/char/digit/matching on data1 result
awardGrep $LINENO  "words.*30"   data1.result 2
awardGrep $LINENO  "chars.*164"  data1.result 2
awardGrep $LINENO  "lines.*4"    data1.result 2
awardGrep $LINENO  "digit.*0.*0" data1.result 2
awardGrep $LINENO  "matched"     data1.result 2



#Run and grade the students program on data2-------------------------------------
logMsg $LINENO "Note:  Grading file, data2"
./$EXE -m cp <data2   >data2.result 2>>$errMsg

#Grade word/line/char/digit/matching on data2 result
awardGrep $LINENO  "words.*25"   data2.result 1
awardGrep $LINENO  "chars.*171"  data2.result 1
awardGrep $LINENO  "lines.*9"    data2.result 1
awardGrep $LINENO  "digit.*2.*2" data2.result 1
awardGrep $LINENO  "matched.*9"  data2.result 1



#Grade make clean-----------------------------------------------------------------
logMsg $LINENO "Note:  Grade make clean"
make clean
if [ "$?" == 0 ]; then
  logMsg $LINENO "SCORE: make clean exited normally for 2 points"
  score=$[ score + 2 ]
else
  logMsg $LINENO "ERROR: make clean did not exit normally"
fi


#Record score
echo "Grade:  $score points"



