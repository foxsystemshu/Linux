#!/usr/bin/gawk -f
BEGIN {
    print "LOG report\n"
    warning_count=0
    failed_count=0
    torrent_count=0
}

FILENAME ~/dmesg/ && /Warning/ {warning_count++}
FILENAME ~/dmesg/ && /Failed/ {failed_count++}

FILENAME ~/yum.log/ && /transmission/ || /ktorrent/ {
    isTorrentInstalled=1
    print "It looks like we found torrent application(s): "
    print $4
}

END {
    print "Warning: " warning_count " event"
    print "Failed: " failed_count " event"
}