#!/usr/bin/env sh

CALENDAR=$(cal -3)
CURRENT_DATE=$(date +"%A, %d %B %Y")
echo -e " ==CURRENT DATE============\n  $CURRENT_DATE\n ==========================\n$CALENDAR" | less
