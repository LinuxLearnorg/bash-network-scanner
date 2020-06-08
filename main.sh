#!/bin/bash
# Check Ip is alive or not
function is_alive_ping() {
  ping -c 1 $1 > /dev/null
  if [ $? -eq 0 ]
  then
   echo Node with IP: $1 is UP.
  else
   echo Node with IP: $1 is DOWN.
  fi
}
# Convert Ip to int
function ip_to_int() {
    SaveIFS=$IFS
    IFS=.
    typeset -a IParr=($1)
    IFS=$SaveIFS

    result=0
    for ((i=0;i<4;i+=1)); do
        result=$(($result * 256))
        result=$((${IParr[$i]} + $result))
    done

    echo $result
}

# Convert IP from int
function int_to_ip() {
    result=$1
    byte=""
    for ((i=0;i<3;i+=1)); do
        byte=.$(($result % 256))$byte
        result=$(($result / 256))
    done
    echo $result$byte
}

# Calculate bitmask for the 'host' part
function cidr_to_hostmask() {
    echo $(($(($((1 << $1)) - 1)) << $((32 - $1))))
}

function get_network_address() {
    SaveIFS=$IFS
    IFS=.
    typeset -a IParr=($1)
    typeset -a NMarr=($2)
    IFS=$SaveIFS

    echo $((${IParr[0]} & ${NMarr[0]})).$((${IParr[1]} & ${NMarr[1]})).$((${IParr[2]} & ${NMarr[2]})).$((${IParr[3]} & ${NMarr[3]}))
}

# Get the broadcast address from the IP & Subnet mask
function get_broadcast_address() {
    SaveIFS=$IFS
    IFS=.
    typeset -a IParr=($1)
    typeset -a NMarr=($2)
    IFS=$SaveIFS

    echo $((${IParr[0]} | (255 ^ ${NMarr[0]}))).$((${IParr[1]} | (255 ^ ${NMarr[1]}))).$((${IParr[2]} | (255 ^ ${NMarr[2]}))).$((${IParr[3]} | (255 ^ ${NMarr[3]})))
}

############## main func
# Calculations
cidr=$2
ip=$1
hostmask=$(cidr_to_hostmask $cidr)
subnet=$(int_to_ip $hostmask)
netaddr=$(get_network_address $ip $subnet)
broadcast=$(get_broadcast_address $ip $subnet)
startip=$(ip_to_int $netaddr)
startip=$((startip+1))
endip=$(ip_to_int $broadcast)

for ((i=startip;i<endip;i+=1)); do
IP=$(int_to_ip $i)
is_alive_ping $IP
done
