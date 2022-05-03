#!/usr/bin/gawk -f
BEGIN {print "LOG report"}

{
    text = $1 "home" $6
    print text
}
