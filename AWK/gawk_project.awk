#!/usr/bin/gawk -f
BEGIN {print "LOG report\n"}

/Warning/ {warning_count++}
/Failed/ {failed_count++}

END {
    print "Warning: " warning_count "event"
    print "Failed: " failed_count "event"
}