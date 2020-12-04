#!/bin/bash

#$ -S /bin/bash
#$ -o /ifshome/mhapenney/logs -j y

#$ -q compute.q
#------------------------------------------------------------------

# CONFIG - petproc.config
CONFIG=${1}

source utils.sh

utils_setup_config ${CONFIG}


#NOTE=${out}_pet_processing_notes.txt

#------------------------------------------------------------------
echo "Reference regions: ${FScerebellum[@]}"

for subj in ${SUBJECT[@]}; do
for cere in ${FScerebellum[@]}; do

utils_setup_config ${CONFIG}

# Test
echo ${subj}
echo ${RRLABELFS}
echo ${cere}


if [ ! -d ${PET_OUT} ]
        then
        mkdir -p ${PET_OUT}
fi

#------------------------------------------------------------------

# STEP (1) EXTRACT REFERENCE REGION FROM APARC+ASEG
echo "Stage 2: Step 1 --> ${subj} ${cere} FS reference region extracted."

cmd="${REGIONEXTRACT} ${MPRAGE}/${subj}_aparc+aseg.nii.gz ${RRLABELFS} ${PET_OUT}/${subj}_aparc+aseg_ref_${cere}.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 2: Step 1]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}

## STEP (2) REGISTER REFERENCE REGION (FS SPACE) TO T1 SPACE
echo "Stage 2: Step 2 --> ${subj} REGISTER REFERENCE FREESURFER TO T1 SPACE"
cmd="${FSLFLIRT} \
     -in ${PET_OUT}/${subj}_aparc+aseg_ref_${cere}.nii.gz \
     -ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
     -applyxfm -init ${T1}/${subj}_orig_to_native.xfm
     -out ${PET_OUT}/${subj}_aparc+aseg_native_ref_${cere}.nii.gz \
     -interp nearestneighbour \
     -datatype float"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 2: Step 2]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}

# STEP (3) BINARIZE EXTRACTED REFERENCE REGION
echo "Stage 2: Step 3 --> ${subj} ${cere} binarized."
cmd="${FSLMATHS} ${PET_OUT}/${subj}_aparc+aseg_native_ref_${cere}.nii.gz -bin ${PET_OUT}/${subj}_aparc+aseg_native_ref_${cere}_bin.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 2: Step 2]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}

chmod 775 -R ${PET_OUT}
cd ${project_conf}
done
done

