#!/usr/bin/gawk -f
BEGIN {
    print "Report"
    print "-----------"
    warning_count=0
    failed_count=0
    torrent_count=0
    Info_count=0
}

FILENAME !~/yum.log/ && /Warning/ {warning_count++}
FILENAME !~/yum.log/ && /Failed/ {failed_count++}
FILENAME !~/yum.log/ && !/Failed/ && !/Warning/ {Info_count++}

FILENAME ~/yum.log/ && (/transmission/ || /torrent/) {
    print "It looks like we found torrent application: "  $4
    torrent_count++
}

END{
    if(FILENAME ~/yum.log/){
        print "\n\nAltogether: " torrent_count " packages"
    } else {
        print "Warning: " warning_count " event"
        print "Failed: " failed_count " event"
        print "Info: " Info_count " event"
    }
    
}

