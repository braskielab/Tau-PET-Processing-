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
for ROI in ${weightedroi[@]};do
utils_setup_config ${CONFIG}


#Test
echo ${LABEL}; echo ${ROI};
#------------------------------------------------------------------
# Qsub convention
#------------------------------------------------------------------

#STAGE 8 - PET ROI Analysis

#------------------------------------------------------------------

#ROI ANALYSES
	if [ ! -d ${WEIGHTED} ]
	then
	mkdir -p ${WEIGHTED}
	fi

#------------------------------------------------------------------
#EXTRACT ROI FROM APARC+ASEG
#------------------------------------------------------------------
echo "STAGE 12: STEP 1 --> Running ${REGIONEXTRACT}"
${REGIONEXTRACT} ${T1}/${subj}_aparc+aseg_to_native.nii.gz ${LABEL} ${WEIGHTED}/${subj}_T1_${ROI}.nii.gz

# Binarize
echo "STAGE 12: STEP 2 --> Thesholding and binarizing ${ROI}"
${FSLMATHS} ${WEIGHTED}/${subj}_T1_${ROI}.nii.gz -thr 0.5 -bin ${WEIGHTED}/${subj}_T1_${ROI}_bin.nii.gz


#------------------------------------------------------------------
#STEP (3) - TRANSFORM NATIVE T1 ROIS to PET SPACE (APPLY T12PET MATRIX)
#------------------------------------------------------------------
echo "STAGE 12: STEP 3 --> ${subj} FS ROIs TRANSFORMED FROM T1 NATIVE SPACE TO PET PET"
cmd="${FSLFLIRT}
	-in ${WEIGHTED}/${subj}_T1_${ROI}_bin.nii.gz
	-ref ${PET_OUT}/${subj}_cereMNI_ref_adj_TAUpet.nii.gz \
	-applyxfm \
	-init ${PET_OUT}/${subj}_mritoTAUPET.xfm \
	-out ${WEIGHTED}/${subj}_PET_${ROI}.nii.gz
    -cost mutualinfo
    -datatype float"


eval ${cmd}
touch ${NOTE}
echo -e "STAGE 12: STEP 3 --> ${subj} FS ROIs TRANSFORMED FROM T1 NATIVE SPACE TO PET PET \r\n" >> ${NOTE}
echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

#------------------------------------------------------------------
#STEP (4) - THRESHOLD & BINARIZE EXTRACTED PET ROI
#------------------------------------------------------------------
echo "STAGE 12: STEP 4 --> ${subj} PET ROI ${ROI} BINARIZE"
cmd="${FSLMATHS} ${WEIGHTED}/${subj}_PET_${ROI}.nii.gz -thr .5 -bin ${WEIGHTED}/${subj}_PET_${ROI}_bin.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 12: STEP 4 --> ${subj} PET ROI ${ROI} BINARIZE  \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


#------------------------------------------------------------------
#STEP (5) - MULTIPLY ROI MASK BY PET TO GET PET REGIONS
#------------------------------------------------------------------
echo "STAGE 12: STEP 5 -->  ${subj} ROI ${ROI} REGION MASK MULTIPLIED TO PET BET"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -mul ${WEIGHTED}/${subj}_PET_${ROI}_bin.nii.gz ${WEIGHTED}/${subj}_TAUPET_${ROI}.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 12: STEP 5 -->  ${subj} ROI ${ROI} REGION MASK MULTIPLIED TO PET  \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

cd ${project_conf}
done

chmod -R 775 ${PET_OUT}

chmod -R 775 ${ROIDIR}

chmod -R 775 ${WEIGHTED}

chmod -R 775 ${FSSPACE}

chmod -R 775 ${T1SPACE}

cd ${project_conf}
done
