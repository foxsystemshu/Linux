# Created by: Németh Szabolcs (EGOJHI)
# Description:
# This AWK script is for print a log report to the console screen.
# The script search for prohibited application installation in package manager log like torrent clients, and so on..
# If we give system log file to the script, it categorizes to 3 group (Warning, Failed, Info) and print how many events it has counted in each of the 3 groups

# Test cases:
# OS: CentOS 7
#  - gawk -F: -f gawk_project.awk /var/log/yum.log
#  - gawk -F: -f gawk_project.awk /var/log/dmesg
#  - journalctl >> journalctl.log &&  gawk -F: -f gawk_project.awk journalctl.log

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

