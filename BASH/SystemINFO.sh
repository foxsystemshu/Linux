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

    Vendor_ID=$(cat /proc/cpuinfo | grep 'vendor_id' | cut -f2 -d":" | sed 's/^ *//g' )
    Model_name=$(cat /proc/cpuinfo | grep 'model name' | cut -f2 -d":" | sed 's/^ *//g')
    CPU_MHz=$(cat /proc/cpuinfo | grep 'cpu MHz' | cut -f2 -d":" | sed 's/^ *//g')
    CAHCE_SIZE=$(cat /proc/cpuinfo | grep 'cache size' | cut -f2 -d":" | sed 's/^ *//g')
    CPU_CORE_NUM=$(cat /proc/cpuinfo | grep 'cpu cores' | cut -f2 -d":" | sed 's/^ *//g')
    CPUID_LEVEL=$(cat /proc/cpuinfo | grep 'cpuid level' | cut -f2 -d":" | sed 's/^ *//g')

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
function get_NET_info {

}

function get_hw_info { 

   CPU=$(get_CPU_info)
   MEM=$(get_MEM_info)
   echo $root_xml_start $CPU $MEM $root_xml_end | xmllint --format -
   
}

get_hw_info

