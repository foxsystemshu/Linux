#!/usr/bin/gawk -f
BEGIN {
    print "Report"
    print "-----------"
    warning_count=0
    failed_count=0
    torrent_count=0
    Info_count=0
}

FILENAME ~/dmesg/ && /Warning/ {warning_count++}
FILENAME ~/dmesg/ && /Failed/ {failed_count++}
FILENAME ~/dmesg/ && !/Failed/ && !/Warning/ {Info_count++}

FILENAME ~/yum.log/ && /transmission/ || /ktorrent/ {
    print "It looks like we found torrent application: "  $4
    torrent_count++
}

END{
    if(FILENAME ~/dmesg/){
        print "Warning: " warning_count " event"
        print "Failed: " failed_count " event"
        print "Info: " Info_count " event"
    } else if(FILENAME ~/yum.log/){
        print"\n\n Altogether: " torrent_count
    }
    
}

