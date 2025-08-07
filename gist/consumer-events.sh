# This script processes a log file produced by a GSS consumer. It focuses
# only on the first task in the ingestion process -- the download itself.

if [ "$1" == "" ]; then
    1>&2 echo You must specify log file
    exit
fi

# Date from the first line in the log file
DSTR=`head -n1 $1 | awk -F"[][ ]" '{print $6}'`

printf "$DSTR "

# Totals
grep '1/4' $1 | awk -F"[ ()]" 'BEGIN {sum=0; count=0; ms=0} {sum+=$12; count++; ms+=$21} END {printf("Total download %9.2f GB in %6d files, %0.1f hrs clocked (~%5.2f Gbps)", sum / 1000000000, count, ms / 3600000, sum / 100000 / ms)  }'

#printf "\n"
#exit
# Concurrent downloads
grep '1/4' $1 | awk '{print $1 " " $2 " " $16}' | sed 's/\]\[INFO//' | sed 's/.*\[//' | sed 's/(//' | awk '{
    end=$1 " " $2
    duration_ms=$3
    dura+=duration_ms

    # Replace comma with dot for `date` compatibility
    gsub(",", ".", end)

    # Calculate seconds and milliseconds separately
    duration_sec = duration_ms / 1000;
#    print "Duration: " duration_sec "(" duration_ms ")";

    cmd = "date -d \"" end "\" +%s"
    cmd | getline end_epoch
    close(cmd)

#    print "End epoch " end_epoch;

    # Compute start epoch as float
    start_epoch = sprintf("%1.3f",  end_epoch - duration_ms / 1000 );
#    printf("Start epoch %s\n", start_epoch);

    # Format start time back into timestamp
    cmd = "date -d @" start_epoch " +\"%Y-%m-%d %H:%M:%S,%3N\""
    cmd | getline start
    close(cmd)

    print start " S";
    print $1, $2 " E";
}' | sort | awk 'BEGIN {
    proc=0;
    max=0;
} {
    if($3=="S") proc++;
    if($3=="E") proc--;

    if(proc>max) max=proc;

#    print $1 " " $2 " (" $3 ") " proc;
} END {print ", maximum concurrent " max}'


