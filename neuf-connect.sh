USER=ssowifi.neuf.fr/mkenza
PASS=jet271664
CURL=curl
START="http://www.google.fr/"

echo "1# Try to get $START"

loginurl=`$CURL $START 2>/dev/null | grep "<LoginURL>" | sed -Ee "s/<LoginURL>(.*)<\/LoginURL>/\1/"`

if [ -z "$loginurl" ]; then
	echo "## Already logged"
	exit 1
fi

echo "2# Post the identification $USER"

loginresultsurl=`$CURL -d "FNAME=0&UserName=$USER&Password=$PASS&OriginatingServer=$START" "$loginurl" 2>/dev/null | grep "<LoginResultsURL>" | sed -Ee "s/<LoginResultsURL>(.*)<\/LoginResultsURL>/\1/"`

if [ -z "$loginresultsurl" ]; then
	echo "## WISPr error"
	exit 1
fi

echo "3# Waiting for reply"

message=`$CURL "$loginresultsurl" 2>/dev/null | grep "<ReplyMessage>" | sed -Ee "s/<ReplyMessage>(.*)<\/ReplyMessage>/\1/"`
if [ -z "$message" ]; then
	echo "4# Connected"
	exit 0
else
	echo "## $message"
	exit 1
fi
