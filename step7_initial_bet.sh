#!/bin/bash

#$ -S /bin/bash
#$ -o /ifshome/mhapenney/logs -j y

#$ -q compute.q
#------------------------------------------------------------------

# CONFIG - petproc.config
CONFIG=${1}

source utils.sh

utils_setup_config ${CONFIG}

#------------------------------------------------------------------
for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}

#------------------------------------------------------------------

# Check if directory exists and make if it does not.

if [ ! -d ${PET_OUT} ]
	then
   	mkdir -p ${PET_OUT}
fi

#------------------------------------------------------------------

# STAGE 5 - PET Preprocessing and Initial Skullstrip

#------------------------------------------------------------------

# INSERT INITIAL STEP INTO TEXT FILE
echo -e "STAGE 5: --> ${subj} SKULLSTRIP MASK (SEE ${NOTE} FOR MORE INFORMATION ON PROCESSING STEPS) \r\n" >> ${NOTE}

# REORIENT TO STANDARD  - PET
echo "STAGE 5: STEP 1 --> ${subj} reorient PET"
cmd="${FSLREOR2STD} ${PET}/${subj}/${subj}_TAUPET_BL.nii.gz ${PET_OUT}/${subj}_TAUPET_reorient.nii.gz"

			eval $cmd
			touch ${NOTE}
			echo "STAGE 5: STEP 1 --> ${subj} reorient PET ## DONE ##"
			echo -e "STAGE 5: STEP 1 --> ${subj} reorient PET \r\n" >> ${NOTE}
			echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# ROBUST FOV - PET
echo "STAGE 5: STEP 2 --> ${subj} APPLY ROBUST FOV to PET"
cmd="${FSLROBUST} -i ${PET_OUT}/${subj}_TAUPET_reorient.nii.gz -r ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz"

			eval $cmd
			touch ${NOTE}
			echo "STAGE 5: STEP 2 --> ${subj} APPLY ROBUST FOV to PET ## DONE ##"
			echo -e "STAGE 5: STEP 2 --> ${subj} APPLY ROBUST FOV to PET \r\n" >> ${NOTE}
			echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

# PET PRELIMINARY SKULLSTRIP - replaced by code below
#echo "STAGE 5: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP"
#cmd="${FSLBET} ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz ${PET_OUT}/${subj}_TAUPET_prelim_bet.nii.gz -B -f 0.5 -g -.05"

			#eval $cmd
			#touch ${NOTE}
			#echo "STAGE 5: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP ## DONE ##"
			#echo -e "STAGE 5: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP \r\n" >> ${NOTE}
			#echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

# STEP (7) - REGISTER PET to N4
    echo "STAGE 3: STEP 7 --> ${subj} REGISTER PET TO N4"
    cmd="${FSLFLIRT} \
        -in ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz \
        -ref ${MPRAGE}/${subj}_N4.nii.gz \
        -out ${PET_OUT}/${subj}_TAUPET_to_N4.nii.gz \
        -omat ${PET_OUT}/${subj}_TAUPET_to_N4.mat \
        -dof 6"

        eval $cmd
        echo -e "STAGE 3: STEP 7 --> ${subj} REGISTER PET TO N4 \r\n" >> ${NOTE}
        echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

    echo "INVERTING MATRIX"
    convert_xfm -omat ${PET_OUT}/${subj}_TAUPET_to_N4_inv.mat -inverse ${PET_OUT}/${subj}_TAUPET_to_N4.mat

# STEP (7b) - REGISTER N4 BRAIN TO PET
    echo "STAGE 3: STEP 7b --> ${subj} REGISTER N4 BRAIN TO PET"
    cmd="${FSLFLIRT} \
        -in ${MPRAGE}/${subj}_N4_brain.nii.gz \
        -ref ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz \
        -applyxfm -init ${PET_OUT}/${subj}_TAUPET_to_N4_inv.mat \
        -out ${PET_OUT}/${subj}_N4_brain_to_TAUPET.nii.gz \
        -dof 6"

        eval $cmd
        echo -e "STAGE 3: STEP 7 --> ${subj} REGISTER N4 BRAIN TO PET \r\n" >> ${NOTE}
        echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

# STEP (8) - BINARIZE N4 AND RUN INITIAL SKULLSTRIP
    echo "STAGE 3: STEP 8 --> ${subj} BINARIZE N4 BRAIN IN PET SPACE"
    cmd="fslmaths ${PET_OUT}/${subj}_N4_brain_to_TAUPET.nii.gz -thr 0.5 -bin ${PET_OUT}/${subj}_N4_brain_to_TAUPET_bin.nii.gz"

        eval $cmd
        echo -e "STAGE 3: STEP 8 --> BINARIZE N4 BRAIN IN PET SPACE \r\n" >> ${NOTE}
        echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

# STEP (9) - INITIAL SKULLSTRIP
    echo "STAGE 3: STEP 9 --> ${subj} INITIAL SKULLSTRIP"
    cmd="fslmaths ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz -mul ${PET_OUT}/${subj}_N4_brain_to_TAUPET_bin.nii.gz ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz"

        eval $cmd
        echo -e "STAGE 3: STEP 9 --> ${subj} INITIAL SKULLSTRIP \r\n" >> ${NOTE}
        echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

#------------------------------------------------------------------
# PET Registration to MRI T1 Space
#------------------------------------------------------------------
# Calculate linear transformation matrix

cmd="${FSLFLIRT} \
    -in ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz \
    -ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
    -out ${PET_OUT}/${subj}_PET_to_native.nii.gz \
    -omat ${PET_OUT}/${subj}_PETtomri.xfm
    -dof 6 \
    -cost mutualinfo"

cmd2="${FSLFLIRT} \
    -in ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz \
    -ref ${MPRAGE}/${subj}_orientROBUST_brain.nii.gz \
    -out ${PET_OUT}/${subj}_PET_to_native.nii.gz \
    -omat ${PET_OUT}/${subj}_PETtomri.xfm
    -dof 6 \
    -cost mutualinfo"

if [[ -f "$N4" ]]; then
 eval ${cmd}
 touch ${NOTE}
 echo -e "STAGE 3: STEP 10 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##"
 echo -e "STAGE 3: STEP 10 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}
else
 eval ${cmd2}
 touch ${NOTE}
 echo -e "STAGE 3: STEP 10 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##"
 echo -e "STAGE 3: STEP 10 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd2}\r\n" >> ${NOTE}
fi

# Calculate inverse inverse transformation matrix

cmd="${FSLXFM} \
    -omat ${PET_OUT}/${subj}_mritoPET.xfm
    -inverse ${PET_OUT}/${subj}_PETtomri.xfm"
eval ${cmd}
touch ${NOTE}
echo -e "STAGE 3: STEP 11 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE ## DONE ##"
echo -e "STAGE 3: STEP 11 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#------------------------------------------------------------------
# PET Registration to MRI T1 Space
#------------------------------------------------------------------
# Calculate linear transformation matrix

cmd="${FSLFLIRT} \
	-in ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz \
	-ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
	-out ${PET_OUT}/${subj}_TAUPET_to_native.nii.gz \
	-omat ${PET_OUT}/${subj}_TAUPETtomri.xfm \
    -cost mutualinfo
    -dof 6"

cmd2="${FSLFLIRT} \
	-in ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz \
	-ref ${MPRAGE}/${subj}_orientROBUST_brain.nii.gz \
	-out ${PET_OUT}/${subj}_TAUPET_to_native.nii.gz \
	-omat ${PET_OUT}/${subj}_TAUPETtomri.xfm
    -cost mutualinfo
    -dof 6"

if [[ -f "$N4" ]]; then
 eval ${cmd}
 touch ${NOTE}
 echo -e "STAGE 5: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##" 
 echo -e "STAGE 5: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}
else
 eval ${cmd2}
 touch ${NOTE}
 echo -e "STAGE 5: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##" 
 echo -e "STAGE 5: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd2}\r\n" >> ${NOTE}
fi

# Calculate inverse inverse transformation matrix

cmd="${FSLXFM} \
	-inverse ${PET_OUT}/${subj}_TAUPETtomri.xfm
    -omat ${PET_OUT}/${subj}_mritoTAUPET.xfm"
eval ${cmd}
touch ${NOTE}
echo -e "STAGE 5: STEP 5 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE ## DONE ##" 
echo -e "STAGE 5: STEP 5 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# Insert command with input and output
chmod -R 775 ${PET_OUT}

cd ${project_conf}
done
