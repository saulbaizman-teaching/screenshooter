#!/bin/sh

# AUTHOR
# --
# Saul Baizman
# saul.baizman@massart.edu
# 617 650 2783

INTERVAL=${1:-15}           # default: 15 minutes
DIRECTORY=${2:-~/Desktop}   # default: Desktop folder

SELF=${0##*/}  
LOGFILE=${SELF%.*}.log

SLEEP=$(which sleep)
DATE=$(which date)
DATE_FORMAT="%Y-%m-%d at %H.%M.%S"

SCREENCAPTURE=$(which screencapture)
SCREENCAPTURE_FILE_FORMAT=png
SCREENCAPTURE_ARGS="-m -t ${SCREENCAPTURE_FILE_FORMAT} -T 0 -x"
# man (1) screencapture
# -m: only capture the main monitor.
# -t png: image format to create, default is png (other options include pdf, jpg, tiff and other formats).
# -T 0: take the picture after a delay of 0 seconds, default is 5.
# -x: do not play sounds.
SCREENCAPTURE_FILENAME_PREFIX="screenshot"

GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# toggle debug mode
DEBUG=false

${DEBUG} && echo \*\*\*\*\* DEBUG ENABLED \*\*\*\*\*
${DEBUG} && echo
${DEBUG} && echo INTERVAL: ${INTERVAL}
${DEBUG} && echo DIRECTORY: ${DIRECTORY}
${DEBUG} && echo SELF: ${SELF}
${DEBUG} && echo LOGFILE: ${LOGFILE}
${DEBUG} && echo SLEEP: ${SLEEP}
${DEBUG} && echo DATE: ${DATE}
${DEBUG} && echo DATE_FORMAT: ${DATE_FORMAT}
${DEBUG} && echo SCREENCAPTURE: ${SCREENCAPTURE}
${DEBUG} && echo SCREENCAPTURE_FILE_FORMAT: ${SCREENCAPTURE_FILE_FORMAT}
${DEBUG} && echo SCREENCAPTURE_ARGS: ${SCREENCAPTURE_ARGS}
${DEBUG} && echo SCREENCAPTURE_FILENAME_PREFIX: ${SCREENCAPTURE_FILENAME_PREFIX}
${DEBUG} && echo

# sanity checks

# is the interval a number greater than zero? let's hope it's an integer.
if [ "${INTERVAL}" -eq 0 ] > /dev/null 2>&1
then
    echo
    echo Setting the interval to zero doesn\'t make sense. Exiting.
    echo
    exit
fi

if [ "${INTERVAL}" -gt 0 ] > /dev/null 2>&1
then
    true # do nothing
else
    echo
    echo \"${INTERVAL}\" is not a valid interval. Exiting.
    echo
    exit
fi

# does the folder exist?
if [[ ! -d ${DIRECTORY} ]]
then
    echo
    echo The folder \"${DIRECTORY}\" doesn\'t exist. Exiting.
    echo
    exit
fi

cat << EOF

Hi! Welcome to ${SELF}.

This program takes a screenshot of your primary desktop every ${INTERVAL} minutes.

The screenshots are stored in ${DIRECTORY}.

To stop this program, press Control + C in the Terminal or quit the
Terminal program.

--

Hint: you can set the interval and location where screenshots are stored when 
invoking the program:

% ${0} <interval in minutes> <folder name>

For example, the text below will take screenshots every 30 minutes and save 
them to your desktop:

% ${0} 30 ~/Desktop

(Do not copy the percent sign above when running the command.)

EOF

# convert minutes to seconds 
((seconds_to_pause=60*${INTERVAL}))

# infinite loop
while true
do
    screenshot_timestamp=$(${DATE} +"${DATE_FORMAT}")
    screenshot_filename="${DIRECTORY}/${SCREENCAPTURE_FILENAME_PREFIX} ${screenshot_timestamp}.${SCREENCAPTURE_FILE_FORMAT}"

    ${DEBUG} && echo screenshot_timestamp: ${screenshot_timestamp}
    ${DEBUG} && echo screenshot_filename: ${screenshot_filename}
    ${DEBUG} && echo

    # take screenshot
    ${SCREENCAPTURE} ${SCREENCAPTURE_ARGS} "${screenshot_filename}"
    # https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
    echo ${GREEN}Latest screenshot: ${NO_COLOR}\"${screenshot_filename}\"
    ${DEBUG} && echo ${SCREENCAPTURE} ${SCREENCAPTURE_ARGS} \"${screenshot_filename}\"
    ${DEBUG} && echo

    echo
    echo To stop this program, press Control + C in the Terminal or quit the
    echo Terminal program.
    echo

    # pause
    # https://serverfault.com/questions/532559/bash-script-count-down-5-minutes-display-on-single-line    
    while [ ${seconds_to_pause} -gt 0 ]
    do
        printf "The next screenshot will be taken in %02d seconds...\033[0K\r" ${seconds_to_pause}
        ${SLEEP} 1
        ((seconds_to_pause-=1))
    done

    # reset value of ${seconds_to_pause}
    if [ ${seconds_to_pause} -eq 0 ]
    then
        ((seconds_to_pause=60*${INTERVAL}))
    fi
done