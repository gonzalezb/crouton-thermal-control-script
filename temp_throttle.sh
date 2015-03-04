#!/bin/bash

# License: GNU GPL 3.0
# Usage: Toshiba Chromebook 2 Crouton thermal control script
# USE CELSIUS TEMPERATURES.
# version 1.0

cat << EOF
Author: Brenden Gonzalez 2015 (brendenrichardgonzalez@gmail.com)
URL: https://github.com/gonzalezb/crouton-thermal-control-script

EOF


err_exit () {
	echo ""
	echo "Error: $@" 1>&2
	exit 128
}

if [ $# -ne 1 ]; then
	MAX_TEMP=51
fi

LOW_TEMP=$((MAX_TEMP - 5))

CORES=$(nproc)
echo -e "Number of CPU cores detected: $CORES\n"
CORES=$((CORES - 1))

MAX_TEMP=${MAX_TEMP}000
LOW_TEMP=${LOW_TEMP}000

FREQ_FILE="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
FREQ_MIN="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq"
FREQ_MAX="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"

if [ -f $FREQ_FILE ]; then
	# If $FREQ_FILE exists, get frequencies from it.
	FREQ_LIST=$(cat $FREQ_FILE) || err_exit "Could not read available cpu frequencies from file $FREQ_FILE"
elif [ -f $FREQ_MIN -a -f $FREQ_MAX ]; then
	# Else if $FREQ_MIN and $FREQ_MAX exist, generate a list of frequencies between them.
	FREQ_LIST=$(seq $(cat $FREQ_MAX) -100000 $(cat $FREQ_MIN)) || err_exit "Could not compute available cpu frequencies"
else
	err_exit "Could not determine available cpu frequencies"
fi

FREQ_LIST_LEN=$(echo $FREQ_LIST | wc -w)

CURRENT_FREQ=2

TEMPERATURE_FILES="
/sys/class/hwmon/hwmon0/device/temp2_input
/sys/class/hwmon/hwmon0/device/temp3_input
null
"

for file in $TEMPERATURE_FILES; do
	TEMP_FILE=$file
	[ -f $TEMP_FILE ] && break
done

[ $TEMP_FILE == "null" ] && err_exit "The location for temperature reading was not found."




set_freq () {
	FREQ_TO_SET=$(echo $FREQ_LIST | cut -d " " -f $CURRENT_FREQ)
	echo $FREQ_TO_SET
	for i in $(seq 0 $CORES); do
		{ echo $FREQ_TO_SET 2> /dev/null > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq; } ||
		{ cpufreq-set -c $i --max $FREQ_TO_SET > /dev/null; } ||
		{ err_exit "Failed to set frequency CPU core$i. Run script as Root user. Some systems may require to install the package cpufrequtils."; }
	done
}

throttle () {
	if [ $CURRENT_FREQ -lt $FREQ_LIST_LEN ]; then
		CURRENT_FREQ=$((CURRENT_FREQ + 1))
		echo -n "throttle "
		set_freq $CURRENT_FREQ
	fi
}

unthrottle () {
	if [ $CURRENT_FREQ -ne 1 ]; then
		CURRENT_FREQ=$((CURRENT_FREQ - 1))
		echo -n "unthrottle "
		set_freq $CURRENT_FREQ
	fi
}

get_temp () {
	
	TEMP=$(cat $TEMP_FILE)
}


# Mainloop
while true; do
	get_temp
	if   [ $TEMP -gt $MAX_TEMP ]; then # Throttle if too hot.
		throttle
	elif [ $TEMP -le $LOW_TEMP ]; then # Unthrottle if cool.
		unthrottle
	fi
	sleep 3 # The amount of time between checking tempuratures.
done
