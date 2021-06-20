#####

experiment_dir="/Users/zg243/Desktop/HD6635/stroop_ds"
preproc_dir="${experiment_dir}/PREPROC"
template_dir="${experiment_dir}/templates"
mask_dir="${template_dir}/PPI"
levelone_dir="${experiment_dir}/LEVELONE"
cd ${data_dir}

for PTP in sub-*; do
	echo "Creating PPI behavioral files for ${PTP}"
	BEHAVDIR="${data_dir}/${PTP}/func"
	echo ${BEHAVDIR}


# CONTRAST (A minus B) REGRESSOR

# Change the 3rd field in the "B" text file from +1 to -1 for baseline task,

	if [ ! -f "${BEHAVDIR}/${PTP}_incongruent_minus_congruent.txt" ]; then
		echo "${PTP} contrast file doesn't exist. Creating!"
		awk '{ print $1,$2,-1 }' ${BEHAVDIR}/${PTP}_congruent.txt > ${BEHAVDIR}/${PTP}_congruenttmp.txt

# Create a numerically sorted union file from two conditions

		sort -n -u ${BEHAVDIR}/${PTP}_congruenttmp.txt ${BEHAVDIR}${PTP}_incongruent.txt > ${BEHAVDIR}/${PTP}_incongruent_minus_congruent.txt

# Clean up temporary files

		rm ${BEHAVDIR}/*tmp.txt

	else
		echo "${PTP} contrast file exists. Skipping!"
	fi
done

# Step 2: Convert mask from standard to individual space

echo "Converting mask file into individual space!"

cd ${mask_dir}

for MASK in SMC_Mask_bin; do
	echo ${MASK}
	for PTP in `cat PTPs.txt` ; do
		if [ ! -f "${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz" ] | [ ! -f "${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_${MASK}.nii.gz" ]; then
			echo "Registering ${MASK} to subject space for ${PTP}"
			mkdir -p ${levelone_dir}/${PTP}.feat/roi/${MASK}/
			flirt -in ${mask_dir}/${MASK} -ref ${levelone_dir}/${PTP}.feat/reg/example_func.nii.gz -applyxfm -init ${levelone_dir}/${PTP}.feat/reg/standard2example_func.mat -out ${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz
			fslmaths ${levelone_dir}/${PTP}.feat/roi/${MASK}/reg_${MASK}.nii.gz -bin ${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_${MASK}.nii.gz
		else
			echo "${MASK} has already been transformed to ${PTP} individual space!"
		fi
	done
done

# PPI step 3: Extract ROI time series

for MASK in SMC_Mask_bin; do
	for PTP in `cat PTPs.txt` ; do
		if [ -d "${levelone_dir}/${PTP}.feat/ppi" ]; then
			echo "PPI directory already exists for ${PTP}"
		else
			mkdir -p ${levelone_dir}/${PTP}.feat/ppi
		fi

		if [ ! -f "${levelone_dir}/${PTP}.feat/ppi/${MASK}_ppi_timecourse.txt" ]; then
			echo "PPI timecourse needs to be extracted for ${PTP} with mask ${MASK}!"
			fslmeants -i ${levelone_dir}/${PTP}.feat/filtered_func_data.nii.gz -o ${levelone_dir}/${PTP}.feat/ppi/${MASK}_ppi_timecourse.txt -m ${levelone_dir}/${PTP}.feat/roi/${MASK}/bin_%{MASK}.nii.gz
		else
			echo "PPI timecourse for ${PTP} with mask ${MASK} has already been extracted!"
		fi
	done
done




