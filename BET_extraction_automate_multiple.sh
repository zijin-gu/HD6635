
## Notes ##
# This code takes is created to automate multiple ways of performing BET extraction 
# Specifically 4 methods will be tried
# 1. Standard 2. robustfov + standard 
# 3. SIENA 4.Robust brain centre estimation 


## Declare Global Variables ###

Project_Dir="/Users/zg243/Desktop/HD6653/stroop_ds"

## Get file with list of participants

cd ${Project_Dir}
find  sub-0* -maxdepth 0 > PTPs.txt

##= Create a list that is the content of the PTPs.txt file
Participants=$(cat ${Project_Dir}/PTPs.txt)

# For each participant, do the following ##

for PTP in ${Participants}
do
	echo $'\nLooping through files for:'${PTP}
	Reoriented="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented.nii.gz"

#BET Structural extraction 
# Standard method
	echo "Performing BET-Extraction on Structural Data using Standard"
	
	if [[ -f ${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_standard.nii.gz ]];then
		echo "Standard BET extracted brain already exists for ${PTP}"
	else
		echo "Extracting Standard"
		Output="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_standard.nii.gz"

		bet ${Reoriented} ${Output} -f 0.5 -g 0 -m -o
	fi

# robustfov + standard
	echo "Performing BET-Extraction on Structural Data using robustfov + Standard"
	if [[ -f ${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_fovstandard.nii.gz ]];then
		echo "fovStandard BET extracted brain already exists for ${PTP}"
	else
		Noneck="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_NoNeck.nii.gz"
		if [[ -f ${Noneck} ]];then

			Output="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_fovstandard.nii.gz"
			bet ${Noneck} ${Output} -f 0.5 -g 0 -m -o
		else
			robustfov -i ${Reoriented} -r ${Noneck}
			Output="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_fovstandard.nii.gz"
			bet ${Noneck} ${Output} -f 0.5 -g 0 -m -o
		fi
	fi

# SIENA
	echo "Performing BET-Extraction on Structural Data using Bias Field and Neck Cleanup (SIENA)"
	if [[ -f ${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_SIENA.nii.gz ]];then
		echo "fovStandard BET extracted brain already exists for ${PTP}"
	else
		Output="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_SIENA.nii.gz"

		bet ${Reoriented} ${Output} -B -f 0.5 -g 0 -m -o
	fi

# Robust brain centre estimation
	echo "Performing BET-Extraction on Structural Data using robust brain centre estimation"
	
	if [[ -f ${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_robust.nii.gz ]];then
		echo "Robust BET extracted brain already exists for ${PTP}"
	else
		Output="${Project_Dir}/${PTP}/anat/${PTP}_T1W_oriented_brain_robust.nii.gz"

		bet ${Reoriented} ${Output} -R -f .5 -m -o
	fi

# #BET functional extraction 
	# echo "Performing BET-Extraction on Functional Data"
	Func_Dir=${Project_Dir}/${PTP}/func
	
	TR_Corrected_Image=${Func_Dir}/${PTP}_task-stroop_bold_1.5TR.nii.gz
	Bet_func_image=${Func_Dir}/${PTP}_task-stroop_bold_1.5TR_brain.nii.gz

	if [[ -f ${Bet_Corrected_Image} ]]; then
		echo "Skull stripping for functional data already completed for ${PTP}"
	else
		echo "Skull stripping functional data for ${PTP}"

		Output_Functional=${Func_Dir}/${PTP}_task-stroop_bold_1.5TR_brain.nii.gz

		bet ${TR_Corrected_Image} ${Output_Functional} -F -o
	fi

	echo $'\nCompleted Structural and Functional brain extractions for:\n'${PTP}
done