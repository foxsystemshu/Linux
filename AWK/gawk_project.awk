#!/usr/bin/gawk -f
BEGIN {print "LOG report"}

/Warning/ {warning_count++}

END {print "Warning:" warning_count}