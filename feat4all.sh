#!/bin/bash

project_dir="/Users/zg243/Desktop/HD6653/stroop_ds"
preproc_dir="${project_dir}/PREPROC"
template_dir="${project_dir}/template"

cd ${project_dir}
find  sub-0* -maxdepth 0 > PTPs.txt
Participants=$(cat ${project_dir}/PTPs.txt)

for PTP in ${Participants}; do
	if [[ -f ${template_dir}/preproc_${PTP}.fsf ]]; then
		echo "Design file exists for ${PTP}!"
	else
		echo "Design file doesn't exist for ${PTP}. Creating one now! "
		sed "s/sub-001/${PTP}/g" ${template_dir}/preproc_template.fsf > ${template_dir}/preproc_${PTP}.fsf
		echo "Finished!"
	fi

	if [[ -d  ${preproc_dir}/${PTP}.feat ]]; then
		echo "Feat directory exists for ${PTP}!"
	else
		echo "Feat directory doesn't exist for ${PTP}. Creating one now! "
		feat ${template_dir}/preproc_${PTP}.fsf ${preproc_dir}/${PTP}.feat
		echo "Finished!"
	fi
done

