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

#STAGE 2 - RECOMBINE INTO A CO-REGISTERED DYNAMIC IMAGE SET BY TAKING AVERAGE

#------------------------------------------------------------------


cd ${timepoints}; chmod 775 *

avgcheck=(${DIROUT}/*);
echo ${#avgcheck[@]}

    #if [ ${#avgcheck[@]} > 7 ]; then

        cmd="${FSLMATHS} ${timepoints}/${subj}_1out.nii.gz -add ${timepoints}/${subj}_2out.nii.gz -add ${timepoints}/${subj}_3out.nii.gz -add ${timepoints}/${subj}_4out.nii.gz -add ${timepoints}/${subj}_5out.nii.gz -add ${timepoints}/${subj}_6out.nii.gz -div 6 ${DIROUT}/${subj}_TAUPET_BL -odt float"  
        eval ${cmd}

    #elif [ ${#avgcheck[@]} == 0 ]; then
    #    echo "No scans to average chief."    

    #else    
       # cmd2="${FSLMATHS} ${timepoints}/${subj}_1out.nii.gz -add ${timepoints}/${subj}_2out.nii.gz -add ${timepoints}/${subj}_3out.nii.gz -add ${timepoints}/${subj}_4out.nii.gz -add ${timepoints}/${subj}_5out.nii.gz -div 5 ${DIROUT}/${subj}_TAUPET_BL -odt float"
    #    eval ${cmd2};

    #fi

    if [ ! -d ${timepointscans} ]; then
        mkdir -p ${timepointscans}
    fi

cd ${DIROUT}; chmod 775 *
cd ${project_conf}
chmod 775 *
done
