#!/bin/bash

usage() { echo "Usage: $0 -s <source directory> -d <destination directory> -w <Allowed wifi SSIDs, comma seperated>" 1>&2; exit 1; }

if [ $# -eq 0 ];
then
    usage
    exit 0
else
  while getopts ":s:d:w:" opt; do
    case ${opt} in
      s)
          SOURCE=$OPTARG
          ;;
      d)
          DESTINATION=$OPTARG
          ;;
      w)
          ALLOWEDWIFI=$OPTARG
          ;;
      \?)
          usage
          ;;
      :)
          usage
          ;;
    esac
  done
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Lets assume we are in a bad state.
NETWORKOK=false
POWEROK=false

timestamp () {
echo $(date -u +"%Y-%m-%dT%H:%M:%SZ")
}

datestamp () {
echo $(date "+%Y-%m-%d")
}

shortdatestamp () {
echo $(date "+%Y%m%d")
}

getcurrentssid () {
echo $(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
}

getcurrentbattery () {
echo $(pmset -g batt | head -n 1 |sed "s/\'//g"| awk '{print $4 $5}')
}

IFS=',' read -r -a WIFIS <<< "$ALLOWEDWIFI"
# echo "${WIFIS[0]}"

for i in "${WIFIS[@]}"
do
  if [[ $i == $(getcurrentssid) ]]; then
    # echo "$i"
  	NETWORKOK=true
  fi
done

if [[ 'ACPower' == $(getcurrentbattery) ]]; then
  	POWEROK=true
elif [[ 'BatteryPower' == $(getcurrentbattery) ]]; then
  	POWEROK=false
  	exit 1
else
    # Maybe some form of solar power? Who knows!
    POWEROK=false
    exit 1
fi

# Let's do some overly rigerous testing to see if our source and destination actually exist before
# bothering to go any further. Just exit out if we think there is a problem.

if [[ -e "$SOURCE" && -e "$DESTINATION" ]]; then
	if [[ "$NETWORKOK" == true &&  "$POWEROK" == true ]]; then
		#echo "Good to sync!"
		rsync --archive -v "$SOURCE" "$DESTINATION"
	else
		exit 1
	fi
elif [[ ! -e "$SOURCE" && ! -e "$DESTINATION" ]]; then
	# echo "Source dir doesn't exist!"
	# echo "Dest dir doesn't exist!"
	exit 1
elif [[ ! -e "$SOURCE" ]]; then
	# echo "Source dir doesn't exist!"
	exit 1
elif [[ ! -e "$DESTINATION" ]]; then
	# echo "Dest dir doesn't exist!"
	exit 1
else
	# echo "I'm very confused!"
	exit 1
fi


