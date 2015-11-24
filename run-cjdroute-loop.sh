#!/bin/bash

# http://mywiki.wooledge.org/BashFAQ/028
cd "${BASH_SOURCE%/*}" || { echo "Can not find my working directory" ; exit 1 ; }
basedir="$PWD"

progname="cjdns-loop-run"


for f in "/var/log/$USER/" "/var/log/cjdns/" "$HOME/"
do
	echo -n "${progname} Looking for writtable log directory in typical location ($f)... "
	if [[ -w "$f" ]] ; then
		log_dir="$f"
		echo "OK"
		break
	else
		echo "nope"
	fi
done
if [[ ! -w "$log_dir" ]] ; then
	echo "${progname} Could not guess the location of writtable log directory. Will not log." 
	log_file='/dev/null/'
else
	log_file="${log_dir}cjdroute-run.log"
fi


for f in "$HOME/cjdroute.conf" "$HOME/cjdns/cjdroute.conf" "/etc/cjdroute.conf" "$HOME/work/cjdns/cjdroute.conf"  "$HOME/wrk/cjdns/cjdroute.conf"
do
	echo -n "${progname} Looking for config file in typical location ($f)... "
	if [[ -r "$f" ]] ; then
		conf_file="$f"
		echo "OK"
		break
	else
		echo "nope"
	fi
done
if [[ ! -r "$conf_file" ]] ; then 
	echo "${progname} Could not guess the location of cjdns configuration file. Did you created it yet? Maybe move it to standard location like ~/cjdroute.conf"
	exit 1
fi

echo -e "\n\n${progname} Will run with log_file=($log_file) and conf_file=($conf_file)." | tee -a "$log_file"

time_prev=0
time_old=0

while true
do
	time_old=$time_prev
	time_prev=$time_now
	time_now=$(date +%s)

	time_since_restart=$((time_now - time_old)) # how fast we restart

	if (( time_since_restart < 30 )) ; then # too fast
		time_sleep=30
		echo "${progname} Restarting too fast (restart before previous one was: $time_since_restart seconds ago), will sleep for $time_sleep" | tee -a "$log_file"
		sleep $time_sleep
	fi

	date_now=$(date)
	cd "${base_dir}" # make shure dir is correct
	echo -e "\n\n\n\n${progname} Starting at $date_now\n" >> "$log_file"
	./cjdroute < "$conf_file" &>> "$log_file"
done

