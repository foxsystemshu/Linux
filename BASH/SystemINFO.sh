#!/bin/bash

# Created by: Nemeth Szabolcs (EGOJHI)
# Date: 2022.05.01
# System scanning script..
# It's gather information about the current system, including hardware, installed packages, and users

# Function name: get_hw_info
# Args: none
# HW info: CPU, Architecture, Memory

# Function name: get_packages_info
# Args: none
# Packages info: Name, Version, Architecture

# Function name: get_users_info
# Args: none
# Packages info: Name, Home dir

# Tested linux systems: 
# - CentOS 7 (Kernel: 3.10.0-1160.62.1.el7.x86_64)
# - 

root_xml_start="<system>"
root_xml_end="</system>"
NET_xml=""
HW_xml=""
DISTRO=$(hostnamectl | grep "Operating System" | cut -d":" -f2)

#Install prerequisite package for easy use
 echo "Install prerequisite package for easier use..."
 if [[ $DISTRO == *"CentOS"* ]]
    then
        yum install net-tools -y 2>/dev/null >> /tmp/prerequisites.log
        yum install libxml2-utils -y 2>/dev/null >> /tmp/prerequisites.log
    else
        apt-get install libxml2-utils 2>/dev/null >> /tmp/prerequisites.log
        apt-get install -y net-tools 2>/dev/null >> /tmp/prerequisites.log
    fi

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
    netxml_start="<Network>"
    net_IP_MASK_xml=""
    netxml_end="</Network>"

    line_count=$( ifconfig | grep -e inet[^6] | wc -l)
    for (( i=1; i<=$line_count; i++ ))
    do
       line="$( ifconfig | grep -e inet[^6] | sed "${i}q;d")"
       IP=$( echo $line | cut -f2 -d" ")
       MASK=$( echo $line | cut -f4 -d" " )
       net_IP_MASK_xml+='<ip address="'${IP}'" mask="'${MASK}'"/>'
    done
    
   echo "Gathering Network Informations"
   echo "-----------------------------"
   echo -e "Phase 1. - Default gateway pinging... \n"
   ICMP_testing "192.168.1.1"
    
   echo -e "Phase 2. - Internet testing... \n"
   ICMP_testing "google.com"
   
   echo -e "Phase 3. - Get routing table information... \n"

   ROUTE=$(get_Routing_table)
    
   NET_xml="$netxml_start $net_IP_MASK_xml $ROUTE $netxml_end"

}



function get_hw_info { 
   echo "Gathering Hardware Informations"
   echo "-----------------------------"
   echo -e " Phase 1. - Get CPU information... \n"
   CPU=$(get_CPU_info)
   echo -e " Phase 2. - Get Memory information... \n"
   MEM=$(get_MEM_info)
  
   #echo -e $root_xml_start $CPU $MEM $NET $root_xml_end | xmllint --format - >> result.xml
   HW_xml="$CPU $MEM"
}
packages_xml_start="<InstalledPackages>"
packages_xml_end="</InstalledPackages>"
packages_xml=""

function get_packages_info {
    # we need different cases for different distros
     echo "Gathering Installed packages"
     echo "-----------------------------"

    if [[ $DISTRO == *"CentOS"* ]]
    then
        rpm -qai 2>/dev/null > /tmp/package_list.txt
        lines=$(cat /tmp/package_list.txt | grep -E "^Name[^s]" | cut -d":" -f2 | wc -l)
        packages=""
        for (( i=1; i<=$lines; i++ ))
        do
            pname="$(cat /tmp/package_list.txt | grep -E "^Name[^s]" | cut -d":" -f2 | sed "${i}q;d" | sed 's/^ *//g')"
            version="$(cat /tmp/package_list.txt | grep -E "^Version[^*:]" | cut -d":" -f2 | sed "${i}q;d" | sed 's/^ *//g' )"
            arch="$(cat /tmp/package_list.txt | grep  "^Architecture[^*]" | cut -d":" -f2 | sed "${i}q;d" | sed 's/^ *//g')"
            packages+='<package name="'${pname}'" version="'${version}'" arch="'${arch}'"/>'
        done
    else
        apt list --installed 2>/dev/null > /tmp/package_list.txt
        lines=$(cat /tmp/package_list.txt | wc -l)
        packages=""

        for (( i=2; i<=$lines; i++ ))
        do
            line="$( cat /tmp/package_list.txt | sed "${i}q;d" )"
            
            pname=$(echo $line | cut -f1 -d"/")
            version=$(echo $line | cut -f2 -d" ")
            arch=$(echo $line | cut -f3 -d" ")

            packages+='<package name="'${pname}'" version="'${version}'" arch="'${arch}'"/>'
        done
    fi
    packages_xml="$packages_xml_start $packages $packages_xml_end"
}

users_xml_start="<Users>"
users_xml_end="</Users>"
users_xml=""
function get_users_info {
    echo "Gathering User Informations"
     echo "-----------------------------"
    users=""
    user_list="$(cat /etc/passwd | grep home | awk -F ":" '{print $6}' | awk -F "/" '{print $3}' | grep [^syslog^] )"
    user_num="$(echo $user_list | wc -w)"

    for (( i=1; i<=$user_num; i++ ))
    do
        user="$(echo $user_list | cut -f${i} -d" ")"
        HOME_DIR=$(eval echo ~$user )
        users+='<User name="'${user}'" HomeDirectory="'${HOME_DIR}'"/>'

    done 

    users_xml="$users_xml_start $users $users_xml_end"

}

function create_xml {
    echo -e $root_xml_start $HW_xml $NET_xml $packages_xml $users_xml $root_xml_end | xmllint --format - > result.xml
}

get_hw_info
get_NET_info
get_packages_info
get_users_info

create_xml
