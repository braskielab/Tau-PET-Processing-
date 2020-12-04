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
# STEP (1) - PET SKULL STRIP - changed reference file
echo "STAGE 6: STEP 1 --> ${subj} REGISTER T1 SKULLSTRIP MASK TO PET SPACE"
cmd="${FSLFLIRT}
    -in ${MPRAGE}/${subj}_N4_brain.nii.gz \
    -ref ${PET_OUT}/${subj}_PET_initial_skullstrip.nii.gz \
    -applyxfm \
    -init ${PET_OUT}/${subj}_mritoTAUPET.xfm \
    -out ${PET_OUT}/${subj}_T1skullstripmask_in_TAUPETspace.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "STAGE 6: STEP 1 --> ${subj} REGISTER T1 SKULLSTRIP MASK TO PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

# STEP (2) - THRESHOLD AND BINARIZE MASK
echo "STAGE 6: STEP 2 --> ${subj} THRESHOLD AND BINARIZE T1 SKULLSTRIPPED MASK IN PET SPACE"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_T1skullstripmask_in_TAUPETspace.nii.gz -thr .5 -bin ${PET_OUT}/${subj}_T1skullstripmask_in_TAUPETspace_bin.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 6: STEP 2 --> ${subj} THRESHOLD AND BINARIZE T1 SKULLSTRIPPED MASK IN PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# STEP (3) - MULTIPLY BINARY MASK TO PET IMAGE TO GET PET SKULLSTRIPPED
echo "STAGE 6: STEP 3 --> ${subj} MULTIPLY MASK TO PET TO CREATE SKULLSTRIPPED PET"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz -mul ${PET_OUT}/${subj}_T1skullstripmask_in_TAUPETspace_bin.nii.gz ${PET_OUT}/${subj}_TAUPET_BET.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 6: STEP 3 --> ${subj} MULTIPLY MASK TO PET TO CREATE SKULLSTRIPPED PET \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# STEP (4) - PET SKULL STRIP => Register T1 to PET TO MAKE PRETTY BRAIN PIC
echo "STAGE 6: STEP 4 --> ${subj} REGISTER T1 SKULLSTRIP TO PET SPACE"
cmd="${FSLFLIRT}
	-in ${MPRAGE}/${subj}_N4_brain.nii.gz \
	-ref ${PET_OUT}/${subj}_TAUPET_BET.nii.gz \
	-applyxfm \
	-init ${PET_OUT}/${subj}_mritoTAUPET.xfm \
	-out ${PET_OUT}/${subj}_T1skullstrip_in_TAUPETspace.nii.gz"

cmd2="${FSLFLIRT}
	-in ${MPRAGE}/${subj}_orientROBUST_brain.nii.gz \
	-ref ${PET_OUT}/${subj}_TAUPET_BET.nii.gz \
	-applyxfm \
	-init ${PET_OUT}/${subj}_mritoTAUPET.xfm \
	-out ${PET_OUT}/${subj}_T1skullstrip_in_TAUPETspace.nii.gz"

if [[ -f "$N4" ]]; then
 eval ${cmd}
 touch ${NOTE}
 echo -e "STAGE 6: STEP 4 --> ${subj} REGISTER T1 SKULLSTRIP TO PET SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}
else
 eval ${cmd2}
 touch ${NOTE}
 echo -e "STAGE 6: STEP 4 --> ${subj} REGISTER T1 SKULLSTRIP TO PET SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd2}\r\n" >> ${NOTE}
fi


cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
