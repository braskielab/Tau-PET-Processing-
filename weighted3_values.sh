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
# CREATE CSV FILES --> CALCULATE ROI STATS --> OUTPUT ROI VALUES TO CSV
#------------------------------------------------------------------

#OUTPUT MEAN PET VALUES TO CSV FILE

    if [ ! -e ${WEIGHT_OUT} ]
    then
    touch ${WEIGHT_OUT}
    fi

# CREATE FILE HEADERS

echo 'RID, lh-entorhinal, rh-entorhinal, lh-hippocampus, rh-hippocampus, lh-parahippocampal, rh-parahippocampal, lh-fusiform, rh-fusiform, lh-lingual, rh-lingual, lh-amygdala, rh-amygdala, lh-middletemporal, rh-middletemporal, lh-caudantcing, rh-rostantcing, lh-postcing, rh-postcing, lh-isthmuscing, rh-isthmuscing, lh-insula, rh-insula, lh-inferiortemporal, rh-inferiortemporal, lh-temppole, rh-temppole, lh-superior_frontal, rh-superior_frontal, lh-lateral_orbitofrontal, rh-lateral_orbitofrontal, lh-medial_orbitofrontal, rh-medial_orbitofrontal, lh-frontal_pole, rh-frontal_pole, lh-caudal_middle_frontal, rh-caudal_middle_frontal, lh-rostral_middle_frontal, rh-rostral_middle_frontal, lh-pars_opercularis, rh-pars_opercularis, lh-pars_triangularis, rh-pars_triangularis, lh-lateraloccipital, rh-lateraloccipital, lh-parietalsupramarginal, rh-parietalsupramarginal, lh-parietalinferior, rh-parietalinferior, lh-superiortemporal, rh-superiortemporal, lh-parietalsuperior, rh-parietalsuperior, lh-precuneus, rh-precuneus, lh-bankSuperiorTemporalSulcus, rh-bankSuperiorTemporalSulcus, lh-tranvtemp, rh-tranvtemp, lh-pericalcarine, rh-pericalcarine, lh-postcentral, rh-postcentral, lh-cuneus, rh-cuneus, lh-precentral, rh-precentral, lh-paracentral, rh-paracentral, rh-caudantcing, lh-rostantcing, lh-pars_orbitalis, rh-pars_orbitalis' > ${WEIGHT_OUT};

for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}


#INSERT SUBJECT IDS
printf "\n%s,"  "${subj}" >> ${WEIGHT_OUT}

#------------------------------------------------------------------
for ROI in ${weightedroi[@]};do
utils_setup_config ${CONFIG}


#-----------------------------------------------------------------
#STEP (1) - CALCULATE ROI MEAN SUVR (non reference adjusted)
#-----------------------------------------------------------------
echo "STAGE 14: STEP 1 -->  ${subj} CALCULATE ROI ${ROI} MEAN SUVR (NON REF ADJUSTED)"
PET_MEAN=$(${FSLSTATS} ${WEIGHTED}/${subj}_TAUPET_${ROI}.nii.gz -M)
echo -e "STAGE 14: STEP 1 -->  ${subj} CALCULATE ROI ${ROI} MEAN SUVR = ${PET_MEAN} \r\n" >> ${NOTE}

#-----------------------------------------------------------------
#STEP (2) - INSERT PET VALUES BY ROI
#-----------------------------------------------------------------
echo "STAGE 14: STEP 2 -->  INSERT ${subj} ROI MEAN SUVR IN CSV FILE"
printf "%g," `echo ${PET_MEAN} | awk -F, '{print $1}'` >> ${WEIGHT_OUT}

#sed -i.bak "${PET_MEAN} | awk -F, '{print $1}'" >> ${CSV_OUT}

#-----------------------------------------------------------------
cd ${project_conf}
done


done
