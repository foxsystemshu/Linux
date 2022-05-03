#!/usr/bin/gawk -f
BEGIN {
    print "LOG report\n"
    warning_count=0
    failed_count=0
    torrent_count=0
}

/Warning/ {warning_count++}
/Failed/ {failed_count++}
/transmission/ || /ktorrent/ {
    torrent_count++
    exit
}

END {
    print "Warning: " warning_count " event"
    print "Failed: " failed_count " event"
    print "Torrent program: " torrent_count "counted: " torrents
}