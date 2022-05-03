#!/usr/bin/gawk -f
BEGIN {
    print "Report"
    print "-----------"
    warning_count=0
    failed_count=0
    torrent_count=0
}

FILENAME ~/dmesg/ && /Warning/ {warning_count++}
FILENAME ~/dmesg/ && /Failed/ {failed_count++}
FILENAME ~/dmesg/ && !/Failed/ && !/Warning/ {Info++}

FILENAME ~/yum.log/ && /transmission/ || /ktorrent/ {
    print "It looks like we found torrent application: "
    print $4
}

END{
    if(FILENAME ~/dmesg/){
        print "Warning: " warning_count " event"
        print "Failed: " failed_count " event"
        print "Info:" Info " event"
    }

}

