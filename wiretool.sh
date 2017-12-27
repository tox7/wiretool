#!/bin/bash

#################################
#                               #
#   /  *----------------*  \    #
#  | ( | WireTool v0.12 | ) |   #
#   \  *----------------*  /    #
#                               #
#depends on:                    #
# - wireless_tools              #
# - wpa_supplicant              #
#################################
version='0.12'
#set this to your wireless device
dev='wlp3s0'
#set this to dir to store wpa psks
wpa_dir='/wpa_net'
#set this to your null file locate
null_dev='/dev/null'
#---FUNCTIONS---

function scan_net {
 echo "> scanning nearby networks on ($dev): "
 if [ "${BASH_ARGV[0]}" = "type" ]
 then
  iwlist $dev scan | grep -E "(ESSID:|IE: IEEE)"
 elif [ "${BASH_ARGV[0]}" = "raw" ]
  then
  iwlist $dev scan
 else
  iwlist $dev scan | grep "ESSID:"
 fi
}

function wpa_connect {
 soft_reset
 NAME=$ESSID".conf"
 if [ -f "$wpa_dir/$NAME" ]
 then
  echo "> connecting to wpa secured network ($ESSID):"
  wpa_supplicant -i $dev -c "$wpa_dir/$NAME" -B
  dhcpcd
 else
  echo "> please enter pass for new wpa secured network ($ESSID)"
  echo -n '> pass: '
  read PASS
  wpa_passphrase "$ESSID" $PASS > "$wpa_dir/$NAME"
  wpa_connect
 fi
}

function open_connect {
 soft_reset
 echo "> connecting to open network ($ESSID):"
 iwconfig $dev essid "$ESSID"
 dhcpcd $dev
}

function check_wpa_supplicant {
 if [ "$(ps -e | grep wpa_supplicant)" != "" ]
 then
  return 1
 else
  return 0
 fi
}

function check_dhcpcd {
 if [ "$(ps -e | grep dhcpcd)" != "" ]
 then
  return 1
 else
  return 0
 fi
}

function soft_reset {
 echo "> flushing wireless interface ($dev)"
 check_wpa_supplicant
 local status=$?
 if [ $status -eq 1 ]
 then
  killall wpa_supplicant > $null_dev 2>&1
 fi
 check_dhcpcd
 local status=$?
 while [ $status -eq 1 ]; do
  killall dhcpcd
  check_dhcpcd
  local status=$?
 done
 ip addr flush dev $dev
 ip route flush dev $dev
}

function hard_reset {
 soft_reset
 echo "> resetting the interface ($dev)"
 ip link set $dev down
 ip link set $dev up
}

#---CODE---

if [ "$USER" != 'root' ]
then
 echo '> ERROR: run this command with "sudo".'
 kill $$
fi
case "$1" in
 'scan')
  scan_net
 ;;
 'con')
  ESSID=$2
  if [ "$ESSID" != "" ]
  then
   if [[ "$*" = *'+s+'* ]]
   then
    while [[ "$ESSID" = *'+s+'* ]]; do
     ESSID=${ESSID/+s+/ }
    done
    echo "> $2 reinterpreted as $ESSID"
   fi
   if [ "$3" = "open" ] || [ "$3" = "" ]
   then
    open_connect
   fi
   if [ "$3" = "wpa" ]
   then
    wpa_connect
   fi
  else
   echo "> ERROR: no network specified"
  fi
 ;;
 'flush')
  soft_reset
 ;;
 'reset')
  hard_reset
 ;;
 'version')
  echo "> WireTool v$version"
 ;;
 *)
  echo '> command not recognized'
esac
