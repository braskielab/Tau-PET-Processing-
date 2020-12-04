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
for rr in ${reference[@]};do
utils_setup_config ${CONFIG}
for cere in ${FScerebellum[@]};do
utils_setup_config ${CONFIG}
#------------------------------------------------------------------

# STAGE (7) - MULTIPLY MASK TO FREESURFER REFERENCE
echo "STAGE 7 --> ${subj} MULTIPLY MASK TO FREESURFER REFERENCE"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_cereMNI_native_ref_${rr}_binthr.nii.gz -mul ${PET_OUT}/${subj}_aparc+aseg_native_ref_${cere}_bin.nii.gz ${PET_OUT}/${subj}_cereMNI_native_final.nii.gz"



# Register reference region to pet space
eval ${cmd}

cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
done
done
