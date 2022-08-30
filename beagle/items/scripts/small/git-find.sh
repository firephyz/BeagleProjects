AFTER=$1
BEFORE=$2

LAST=$(git log --after=$AFTER --before=$BEFORE | head -n 1)
FIRST=$(git log --after=$AFTER --before=$BEFORE | tac | sed -nr '{:loop0;/^commit/{p;b loop1};n;b loop0; :loop1; q}')

LAST=$(echo $LAST | awk '{print $2}');
FIRST=$(echo $FIRST | awk '{print $2}');

echo $FIRST $LAST
