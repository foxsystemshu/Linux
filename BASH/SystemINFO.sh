#!/bin/bash

# Created by: Nemeth Szabolcs (EGOJHI)
# Date: 2022.04.9
# System scanning script..
# It's gather information about the current system, including hardware, installed packages, and users

# Function name: get_hw_info
# Args: none
# HW info: CPU, Arch, MEM

# Function name: get_packages_info
# Args: none
# Packages info: Name, Version

# Function name: get_users_info
# Args: none
# Packages info: Name, Home dir, Last logon date
root_xml_start="<system>"
root_xml_end="</system>"

function get_CPU_info {

    #outputs from /proc/cpuinfo --> "vendor_id : VENDOR"

    Vendor_ID=$(cat /proc/cpuinfo | grep 'vendor_id' | head -n 1 | cut -f2 -d":" | sed 's/^ *//g' )
    Model_name=$(cat /proc/cpuinfo | grep 'model name' | head -n 1| cut -f2 -d":" | sed 's/^ *//g')
    CPU_MHz=$(cat /proc/cpuinfo | grep 'cpu MHz' | head -n 1| cut -f2 -d":" | sed 's/^ *//g')
    CAHCE_SIZE=$(cat /proc/cpuinfo | grep 'cache size' | head -n 1| cut -f2 -d":" | sed 's/^ *//g')
    CPU_CORE_NUM=$(cat /proc/cpuinfo | grep 'cpu cores' | head -n 1| cut -f2 -d":" | sed 's/^ *//g')
    CPUID_LEVEL=$(cat /proc/cpuinfo | grep 'cpuid level' | head -n 1 |cut -f2 -d":" | sed 's/^ *//g')

    #outputs from 'lscpu' command

    ARCH=$(lscpu | grep 'Architecture:' | cut -f2 -d":" | sed 's/^ *//g')
    CPU_OP_MODE=$(lscpu | grep 'CPU op-mode(s):' | cut -f2 -d":" | sed 's/^ *//g')
    CPU_NUM=$(lscpu | grep '^CPU(s):' | cut -f2 -d":" | sed 's/^ *//g')
    SOCKETS_NUM=$(lscpu | grep 'Socket(s):' | cut -f2 -d":"| sed 's/^ *//g')

    # Split raw outputs to single string e.g: "vendor_id : VENDOR" --> "VENDOR"
    #Vendor_ID=${Vendor_ID_raw##*:}
    #Model_name=${Model_name_raw#*:}
    #CPU_MHz=${CPU_MHz_raw#*:}
    #CAHCE_SIZE=${CAHCE_SIZE_raw#*:}
    #CPU_CORE_NUM=${CPU_CORE_NUM_raw#*:}
    #CPUID_LEVEL=${CPUID_LEVEL_raw#*:}
    #ARCH=${ARCH_raw#*:}
    #CPU_OP_MODE=${CPU_OP_MODE_raw#*:}
    #CPU_NUM=${CPU_NUM_raw#*:}
    #SOCKETS_NUM=${SOCKETS_NUM_raw#*:}

    cpu_xml="<CPUInfo><VendorID>${Vendor_ID}</VendorID><ModelName>${Model_name}</ModelName><MHz>${CPU_MHz}</MHz><CPUNumber>${CPU_NUM}</CPUNumber><CoreNumber>${CPU_CORE_NUM}</CoreNumber><SocketNumber>${SOCKETS_NUM}</SocketNumber><CPUIDLevel>${CPUID_LEVEL}</CPUIDLevel><Architecture>${ARCH}</Architecture><OPMode>${CPU_OP_MODE}</OPMode></CPUInfo>"

    echo $cpu_xml
}
function get_MEM_info {

    MemTotal=$(cat /proc/meminfo | grep 'MemTotal:' | cut -f2 -d":" | sed 's/^ *//g')
    MemFree=$(cat /proc/meminfo | grep 'MemFree:' | cut -f2 -d":" | sed 's/^ *//g')
    MemAvailable=$(cat /proc/meminfo | grep 'MemAvailable:' | cut -f2 -d":" | sed 's/^ *//g')
    Buffers=$(cat /proc/meminfo | grep 'Buffers:' | cut -f2 -d":" | sed 's/^ *//g')
    SwapTotal=$(cat /proc/meminfo | grep 'SwapTotal:' | cut -f2 -d":" | sed 's/^ *//g')
    SwapFree=$(cat /proc/meminfo | grep 'SwapFree:' | cut -f2 -d":" | sed 's/^ *//g')

    mem_xml="<MemoryInfo><Total>${MemTotal}</Total><Free>${MemFree}</Free><Available>${MemAvailable}</Available><Buffers>${Buffers}</Buffers><SwapTotal>${SwapTotal}</SwapTotal><SwapFree>${SwapFree}</SwapFree></MemoryInfo>"
    
    echo $mem_xml
}
function ICMP_testing {
    ping=$(ping -c4 $1)    #ToDo: Default gateway will be in variable
    ping_received="$( echo $ping | cut -f2 -d",")" 
    ping_loss="$( echo $ping | cut -f3 -d",")"
    ping_times="$( echo $ping | cut -f4 -d",")"

    echo $ping_received
    echo $ping_loss
    echo $ping_times

}

function get_Routing_table {
    table_xml=''
    table_start_xml="<RouteTable>"
    table_end_xml="</RouteTable>"
    
    row_count=$(route | wc -l)
    for (( i=3; i<=$row_count; i++ ))
    do
        route=$(route | sed "${i}q;d")
        dest=$(echo $route | cut -f1 -d" ")
        gateway=$(echo $route | cut -f2 -d" ")
        Genmask=$(echo $route | cut -f3 -d" ")
        Flag=$(echo $route | cut -f4 -d" ")
        Metric=$(echo $route | cut -f5 -d" ")
        Ref=$(echo $route | cut -f6 -d" ")
        Use=$(echo $route | cut -f7 -d" ")
        Interface=$(echo $route | cut -f8 -d" ")

          table_xml+='<route destination="'${dest}'" gateway="'${gateway}'" genmask="'${Genmask}'" flag="'${Flag}'" metric="'${Metric}'" ref="'${Ref}'" use="'${Use}'" interface="'${Interface}'"/>'      
    done

    echo $table_start_xml $table_xml $table_end_xml
}

function get_NET_info {
    net_IP_MASK=""

    line_count=$( ifconfig | grep -e inet[^6] | wc -l)
    for i in 1 $line_count
    do
       line="$( ifconfig | grep -e inet[^6] | sed "${i}q;d")"
       IP=$( echo $line | cut -f2 -d" ")
       MASK=$( echo $line | cut -f4 -d" " )
       net_IP_MASK+="${IP} (${MASK})\n"
    done
   

    echo "Gathering Network Information"
    echo "--------------------------"
    echo -e "Phase 1. - Default gateway pinging... \n"
    ICMP_testing "192.168.1.1"
    
    echo -e "Phase 2. - Internet testing... \n"
    ICMP_testing "google.com"

    echo -e "Phase 3. - Get routing table information... \n"
    #get_Routing_table
    echo -e "$net_IP_MASK"

}



function get_hw_info { 

   CPU=$(get_CPU_info)
   MEM=$(get_MEM_info)
   ROUTE=$(get_Routing_table)
   echo $root_xml_start $CPU $MEM $ROUTE $root_xml_end | xmllint --format - >> result.xml

}

get_hw_info
get_NET_info

