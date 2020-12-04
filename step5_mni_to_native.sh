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

#STAGE 4 - REGISTER MNI TO NATIVE SPACE

#------------------------------------------------------------------
#*********************************
#STEP (1)- REGISTER MNI BRAIN 2 NATIVE T1 BRAIN
echo "STAGE: 3 STEP 1 --> ${subj} REGISTER MNI BRAIN to NATIVE T1 SPACE" 
cmd="${FSLFLIRT} \
	 -in ${mnicerebellum}/MNI152_T1_1mm_brain.nii.gz \
	 -ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
 	 -out ${T1}/${subj}_MNI_to_native.nii.gz \
 	 -omat ${T1}/${subj}_MNI_to_native.xfm \
 	 -dof 12 \
 	 -datatype float"
eval ${cmd}
echo -e "STAGE: 3 STEP 1 --> ${subj} REGISTER MNI to NATIVE T1 SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#STEP (2)- APPLY TRANSFORMATION TO CEREBELLUM LABEL MAP 
#USING NEAREST NEIGHBOUR BECAUSE IT IS A LABEL MAP, NOT! LINEAR
echo "STAGE: 3 STEP 2 --> ${subj} APPLY TRANSFORMATION TO CEREBELLUM MASK"
cmd="${FSLFLIRT} \
 	-in ${mnicerebellum}/Cerebellum-MNIflirt-maxprob-thr0-1mm.nii.gz \
 	-ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
 	-applyxfm -init ${T1}/${subj}_MNI_to_native.xfm \
 	-out ${T1}/${subj}_cereMNI_to_native.nii.gz \
 	-interp nearestneighbour \
 	-datatype float"
eval ${cmd}
echo -e "STAGE: 3 STEP 2 --> ${subj} APPLY TRANSFORMATION TO MNI CEREBELLUM MASK \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}



cd ${T1}
chmod 775 *
cd ${project_conf}
chmod 775 *
done
