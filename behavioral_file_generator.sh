#!/bin/bash

experiment_dir="/Users/zg243/Desktop/HD6653/"
data_dir="${experiment_dir}/stroop_ds"

cd ${data_dir}

Participants=$(cat ${data_dir}/PTPs.txt)

for PTP in ${Participants}; do
	cd ${PTP}/func
	echo "${PTP} behavioral files being generated!"

	awk '/neutral/ {print $1,$2,1}' *events.tsv > ${PTP}_neutral.txt
	awk '/\tcongruent/ {print $1,$2,1}' *events.tsv > ${PTP}_congruent.txt
	awk '/incongruent/ {print $1,$2,1}' *events.tsv > ${PTP}_incongruent.txt

	if [[ -f ${PTP}_neutral.txt ]]; then
		echo "${PTP}_neutral.txt exists!"
	else
		echo "${PTP}_neutral.txt does not exist!"
	fi

	if [[ -r ${PTP}_congruent.txt ]]; then
		echo "${PTP}_congruent.txt exists!"
	else
		echo "${PTP}_congruent.txt does not exist!"
	fi

	if [[ -f ${PTP}_incongruent.txt ]]; then
		echo "${PTP}_incongruent.txt exists!"
	else
		echo "${PTP}_incongruent.txt does not exist!"
	fi

	echo "${PTP} behavioral files have been made!"

	cd ${data_dir}
done