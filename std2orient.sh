#!/bin/bash

cd ~/Desktop/HD6653/stroop_ds/

for (( i = 2; i < 29; i++ )); do
	if [ $i -lt 10 ] ; then
		cp sub-00${i}/anat/sub-00${i}_T1w_std.nii.gz sub-00${i}/anat/sub-00${i}_T1w_oriented.nii.gz
	else
		cp sub-0${i}/anat/sub-0${i}_T1w_std.nii.gz sub-0${i}/anat/sub-0${i}_T1w_oriented.nii.gz
	fi
done