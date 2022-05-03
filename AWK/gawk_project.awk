#!/usr/bin/gawk -f
BEGIN {print "LOG report"}

/Warning/ {warning_count++}
/Failed/ {failed_count++}

END {
    print "Warning: " warning_count "\n"
    print "Failed: " failed_count "\n"
}