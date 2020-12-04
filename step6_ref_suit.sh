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
echo "Reference regions: ${reference[@]}"
# lh-cerebellum-wm, rh-cerebellum-wm

for subj in ${SUBJECT[@]}; do
for rr in ${reference[@]}; do

utils_setup_config ${CONFIG}

# Test
echo ${subj}
echo ${RRLABEL}
echo ${rr}


if [ ! -d ${PET_OUT} ]
        then
        mkdir -p ${PET_OUT}
fi

#------------------------------------------------------------------

#STAGE 4 - EXTRACT CEREBELLUM IN NATIVE SPACE & BINARIZE

#------------------------------------------------------------------

# STEP (1) EXTRACT REFERENCE REGION FROM CEREBELLUM
echo "Stage 4: Step 1 --> ${subj} ${rr} MNI reference region extracted."

cmd="${REGIONEXTRACT} ${T1}/${subj}_cereMNI_to_native.nii.gz ${RRLABEL} ${PET_OUT}/${subj}_cereMNI_native_ref_${rr}.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 4: Step 1]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}


# STEP (2) BINARIZE EXTRACTED CEREBELLUM REGION
echo "Stage 4: Step 2 --> ${subj} ${rr} binarized."
cmd="${FSLMATHS} ${PET_OUT}/${subj}_cereMNI_native_ref_${rr}.nii.gz -thr 0.5 -bin ${PET_OUT}/${subj}_cereMNI_native_ref_${rr}_binthr.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 4: Step 2]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}

chmod 775 -R ${PET_OUT}
cd ${project_conf}
done
done

