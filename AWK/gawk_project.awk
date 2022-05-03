#!/usr/bin/gawk -f
BEGIN {print "LOG report"}

/Warning/ {warning_count++}

END {print warning_count}