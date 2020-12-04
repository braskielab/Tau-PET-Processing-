#!/bin/bash

#$ -S /bin/bash
#$ -o /ifshome/mhapenney/logs -j y

#$ -q compute.q
#------------------------------------------------------------------

# CONFIG - petproc.config
CONFIG=${1}

source utils.sh

utils_setup_config ${CONFIG}
#utils_SGE_TASK_ID_SUBJandSCAN
#------------------------------------------------------------------

for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}

# Parallel Computing
#subj=${SUBJECT[${SGE_TASK_ID}-1]}

#------------------------------------------------------------------

if [ ! -d ${T1} ]
	then
	mkdir ${T1}
fi

if [ ! -d ${NOTE} ]
	then
   	touch ${NOTE}
fi
#------------------------------------------------------------------

#STAGE 1 - REGISTER FREESURFER TO NATIVE SPACE

#------------------------------------------------------------------
#*********************************
#STEP (1)- REGISTER FS ORIG.nii OUTPUT BRAIN 2 NATIVE T1 BRAIN
echo "STAGE: 1 STEP 1 --> ${subj} REGISTER FREESURFER to NATIVE T1 SPACE" 
cmd="${FSLFLIRT} \
	 -in ${MPRAGE}/${subj}_orig.nii.gz \
	 -ref ${MPRAGE}/${subj}_N4.nii.gz \
 	 -out ${T1}/${subj}_orig_to_native.nii.gz \
 	 -omat ${T1}/${subj}_orig_to_native.xfm \
 	 -dof 6"
eval ${cmd}
echo -e "STAGE: 1 STEP 1 --> ${subj} REGISTER FS to NATIVE T1 SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#STEP (2)- APPLY TRANSFORMATION TO APARC+ASEG 
#USING NEAREST NEIGHBOUR BECAUSE IT IS A LABEL MAP, NOT! LINEAR
echo "STAGE: 1 STEP 2 --> ${subj} APPLY TRANSFORMATION TO APARC+ASEG MASK"
cmd="${FSLFLIRT} \
 	-in ${MPRAGE}/${subj}_aparc+aseg.nii.gz \
 	-ref ${MPRAGE}/${subj}_N4.nii.gz \
 	-applyxfm -init ${T1}/${subj}_orig_to_native.xfm \
 	-out ${T1}/${subj}_aparc+aseg_to_native.nii.gz \
 	-interp nearestneighbour"

eval ${cmd}
echo -e "STAGE: 1 STEP 2 --> ${subj} APPLY TRANSFORMATION TO APARC+ASEG MASK \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

# STEP (3) BINARIZE EXTRACTED REFERENCE REGION
echo "Stage 1: Step 3 --> ${subj} ${cere} thresholded and binarized."
cmd="${FSLMATHS} ${T1}/${subj}_aparc+aseg_to_native.nii.gz -thr 0.5 -bin ${PET_OUT}/${subj}_aparc+aseg_to_native.nii.gz"
eval ${cmd}
touch ${NOTE}
echo -e "[[Stage 2: Step 2]]\r\n Command --> ${cmd}\r\n" >> ${NOTE}

cd ${T1}
chmod 775 *
cd ${project_conf}
chmod 775 *
done
