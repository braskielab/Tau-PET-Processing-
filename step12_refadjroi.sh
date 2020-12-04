#!/bin/bash

#$ -S /bin/bash
#$ -o /ifshome/mhapenney/logs -j y

#$ -q compute.q

#------------------------------------------------------------------

# CONFIG - petproc.config
CONFIG=${1}

source utils.sh
utils_setup_config ${CONFIG}

# OUTPUT MEAN PET VALUE TO CSV FILE

   if [ ! -e ${REF_OUT} ]
    then
    touch ${REF_OUT}
    fi

# CREATE FILE HEADERS

echo 'RID, MEAN_CEREBELLUM' > ${REF_OUT};    

#------------------------------------------------------------------
for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}
for ROI in ${regionsofinterest[@]};do
utils_setup_config ${CONFIG}

#------------------------------------------------------------------
# Step (1) Multiply PET BET by reference region mask.  Isolate PET reference region ROI
#------------------------------------------------------------------
echo "STAGE 10: STEP 1 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -mul ${PET_OUT}/${subj}_cereMNI_TAUPET_final.nii.gz ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 10: STEP 1 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK IN PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#------------------------------------------------------------------
# Step (2) Calculate mean PET value in cerebellum white matter region of TAUPET scans
#-----------------------------------------------------------------
echo "STAGE 10: STEP 2 -->  CALCULATE MEAN REFERENCE REGION SIGNAL FOR SUBJECT ${subj} == ${MEAN_REF}"
MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz -M)
echo -e "STAGE 10: STEP 2 --> ${subj} MEAN REFEENCE REGION SIGNAL \r\n" >> ${NOTE}
echo -e "COMMAND -> MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz -M) = ${MEAN_REF} \r\n" >> ${NOTE}

#-----------------------------------------------------------------
#STEP (3) - INSERT PET VALUES BY ROI
#-----------------------------------------------------------------

#INSERT SUBJECT IDS
printf "\n%s,"  "${subj}" >> ${REF_OUT}

echo "STAGE 10: STEP 3 -->  INSERT ${subj} MEAN REF REGION IN CSV FILE"
printf "%g," `echo ${MEAN_REF} | awk -F, '{print $1}'` >> ${REF_OUT}

cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
done
