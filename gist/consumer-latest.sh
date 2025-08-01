# This script finds zip files mentioned in the log and tries to extract the date and time of
# its creation.

if [ "$1" == "" ]; then
    1>&2 echo You must specify log file
    exit
fi


# Date from the first line in the log file
DSTR=`head -n1 $1 | awk -F"[][ ]" '{print $6}'`
printf "$DSTR "

grep '1/4' $1 | grep -o 'S[1-5][A-D]\S*\.zip' | sed 's/.*\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)T\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*/\1-\2-\3 \4:\5:\6/' | sort | tail -n1


