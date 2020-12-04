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

#------------------------------------------------------------------
# STEP (1) - REGISTER REFERENCE REGION (MRI SPACE) TO PET SPACE
#----------------------------------------------------------------

echo "STAGE 8: STEP 1 --> Registering ${subj} MNI cerebellum from MRI space to PET space"
cmd="${FSLFLIRT} \
      -in ${PET_OUT}/${subj}_cereMNI_native_final.nii.gz \
      -ref ${PET_OUT}/${subj}_TAUPET_BET.nii.gz
      -applyxfm -init ${PET_OUT}/${subj}_mritoTAUPET.xfm
      -out ${PET_OUT}/${subj}_cereMNI_TAUPET_final.nii.gz \
      -interp nearestneighbour \
      -datatype float"
eval ${cmd}
echo "STAGE 8: STEP 1 --> Registering ${subj} MNI cerebellum from MRI space to PET space ## DONE ##"

#------------------------------------------------------------------
# STEP (2) Multiply PET BET by reference region mask.  Isolate PET reference region ROI
#------------------------------------------------------------------
echo "STAGE 8: STEP 2 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -mul ${PET_OUT}/${subj}_cereMNI_TAUPET_final.nii.gz ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 8: STEP 2 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK IN PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#------------------------------------------------------------------
# STEP (3) Calculate mean PET value in cerebellum white matter region of TAUPET scans
#-----------------------------------------------------------------
echo "STAGE 8: STEP 3 -->  CALCULATE MEAN REFERENCE REGION SIGNAL FOR SUBJECT ${subj} == ${MEAN_REF}"
MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz -M)
echo -e "STAGE 8: STEP 3 --> ${subj} MEAN REFEENCE REGION SIGNAL \r\n" >> ${NOTE}
echo -e "COMMAND -> MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz -M) = ${MEAN_REF} \r\n" >> ${NOTE}

#-----------------------------------------------------------------
#STEP (4) - INSERT PET VALUES BY ROI
#-----------------------------------------------------------------
echo "STAGE 8: STEP 4 -->  INSERT ${subj} MEAN REF REGION IN CSV FILE"
printf "%g," `echo ${MEAN_REF} | awk -F, '{print $1}'` >> ${REF_OUT}

#sed -i.bak "${PET_MEAN} | awk -F, '{print $1}'" >> ${CSV_OUT}

#-----------------------------------------------------------------

#------------------------------------------------------------------
# STEP (5) Adjust voxelwise PET signal by mean reference region signal
#------------------------------------------------------------------
echo "STAGE 8: STEP 5 --> ADJUST VOXELWISE PET SIGNAL BY MEAN REFERENCE REGION SIGNAL"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -div ${MEAN_REF} ${PET_OUT}/${subj}_cereMNI_ref_adj_TAUpet.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 8: STEP 5 --> ${subj} ADJUST VOXELWISE PET SIGNAL BY MEAN REFERENCE MASK \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

echo "STAGE 8: STEP 6 --> REGISTER REFERENCE ADJUSTED PET TO T1 SKULLSTRIP"
cmd="${FSLFLIRT} \
      -in ${PET_OUT}/${subj}_cereMNI_ref_adj_TAUpet.nii.gz \
      -ref ${PET_OUT}/${subj}_TAUPET_BET.nii.gz
      -out ${PET_OUT}/${subj}_cereMNI_ref_adj_TAUpet.nii.gz \
      -interp nearestneighbour \
      -datatype float"
eval ${cmd}
echo "STAGE 8: STEP 6 --> REGISTER REFERENCE ADJUSTED PET TO T1 SKULLSTRIP ## DONE ##"


cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
done
