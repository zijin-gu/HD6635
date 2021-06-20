#!/bin/bash

project_dir="/Users/zg243/Desktop/HD6653/stroop_ds"
preproc_dir="${project_dir}/PREPROC"
levelone_dir="${project_dir}/LEVELONE"
template_dir="${project_dir}/template"
designfile_dir="${template_dir}/levelone"

cd ${project_dir}

Participants=$(cat ${project_dir}/PTPs.txt)

for PTP in ${Participants}; do
	if [[ -f ${designfile_dir}/LEVELONE_${PTP}.fsf ]]; then
		echo "LevelOne design file exists for ${PTP}!"
	else
		echo "LevelOne design file doesn't exist for ${PTP}. Creating one now! "
		sed "s/sub-001/${PTP}/g" ${template_dir}/LEVELONE_template.fsf > ${designfile_dir}/LEVELONE_${PTP}.fsf
		echo "Finished!"
	fi

	if [[ -d  ${levelone_dir}/${PTP}.feat ]]; then
		echo "Feat directory exists for ${PTP}!"
	else
		echo "Feat directory doesn't exist for ${PTP}. Creating one now! "
		feat ${designfile_dir}/LEVELONE_${PTP}.fsf ${levelone_dir}/${PTP}.feat
		echo "Finished!"
	fi

	ln -s ${preproc_dir}/${PTP}.feat/reg ${levelone_dir}/${PTP}.feat/reg
done