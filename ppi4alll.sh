
experiment_dir="/Users/zg243/Desktop/HD6653/stroop_ds"
preproc_dir="${experiment_dir}/PREPROC"
template_dir="${experiment_dir}/template"
mask_dir="${template_dir}/PPI"
levelone_dir="${experiment_dir}/LEVELONE"
ppi_levelone_dir="${experiment_dir}/PPI/levelone"
SMC_Mask_bin="dlpfc"

cd ${experiment_dir}
Participants=$(cat ${experiment_dir}/PTPs.txt)

# generate needed filed for all subjects
for PTP in ${Participants}; do

	echo "Creating PPI behavioral files for ${PTP}"
	BEHAVDIR="${experiment_dir}/${PTP}/func"
	echo ${BEHAVDIR}

	if [ ! -f "${BEHAVDIR}/${PTP}_incongruent_minus_congruent.txt" ]; then
		echo "${PTP} contrast file doesn't exist. Creating!"
		awk '{ print $1,$2,-1 }' ${BEHAVDIR}/${PTP}_congruent.txt > ${BEHAVDIR}/${PTP}_congruenttmp.txt
		sort -n -u ${BEHAVDIR}/${PTP}_congruenttmp.txt ${BEHAVDIR}/${PTP}_incongruent.txt > ${BEHAVDIR}/${PTP}_incongruent_minus_congruent.txt
		rm ${BEHAVDIR}/*tmp.txt

	else
		echo "${PTP} contrast file exists. Skipping!"
	fi
done

for MASK in ${SMC_Mask_bin}; do
	echo ${MASK}
	for PTP in ${Participants}; do
		if [ ! -f "${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz" ] | [ ! -f "${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_${MASK}.nii.gz" ]; then
			echo "Registering ${MASK} to subject space for ${PTP}"
			mkdir -p ${levelone_dir}/${PTP}.feat/roi/${MASK}/
			flirt -in ${mask_dir}/bin_${MASK}.nii.gz -ref ${levelone_dir}/${PTP}.feat/reg/example_func.nii.gz -applyxfm -init ${levelone_dir}/${PTP}.feat/reg/standard2example_func.mat -out ${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz
			fslmaths ${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz -bin ${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_${MASK}.nii.gz
		else
			echo "${MASK} has already been transformed to ${PTP} individual space!"
		fi
	done
done

for MASK in ${SMC_Mask_bin}; do
	for PTP in ${Participants}; do
		if [ -d "${levelone_dir}/${PTP}.feat/ppi" ]; then
			echo "PPI directory already exists for ${PTP}"
		else
			mkdir -p ${levelone_dir}/${PTP}.feat/ppi
		fi

		if [ ! -f "${levelone_dir}/${PTP}.feat/ppi/${MASK}_ppi_timecourse.txt" ]; then
			echo "PPI timecourse needs to be extracted for ${PTP} with mask ${MASK}!"
			fslmeants -i ${levelone_dir}/${PTP}.feat/filtered_func_data.nii.gz -o ${levelone_dir}/${PTP}.feat/ppi/${MASK}_ppi_timecourse.txt -m ${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_${MASK}.nii.gz
		else
			echo "PPI timecourse for ${PTP} with mask ${MASK} has already been extracted!"
		fi
	done
done

# loop for all subjects
for PTP in ${Participants}; do
	if [[ -d ${ppi_levelone_dir}/${PTP}.feat/stats ]]; then
		echo "feat LEVELONE PPI stats for ${PTP} already exists."
	elif [[ -f ${template_dir}/ppi_levelone_${PTP}.fsf ]]; then
		echo "ppi_levelone_${PTP}.fsf already exists, running feat on this file now!"
		feat ${template_dir}/ppi_levelone_${PTP}.fsf
		ln -s ${preproc_dir}/${PTP}.feat/reg ${ppi_levelone_dir}/${PTP}.feat
	else
		echo "${PTP} levelone fsf file doesn't exist, creating now!"
		sed "s/sub-001/${PTP}/g" ${template_dir}/ppi_levelone_template.fsf > ${template_dir}/ppi_levelone_${PTP}.fsf
		echo "template created, running feat!"
		feat ${template_dir}/ppi_levelone_${PTP}.fsf
		ln -s ${preproc_dir}/${PTP}.feat/reg ${ppi_levelone_dir}/${PTP}.feat
	fi
done
