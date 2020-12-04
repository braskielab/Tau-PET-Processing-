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

# Parallel Computing
#subj=${SUBJECT[${SGE_TASK_ID}-1]}

#------------------------------------------------------------------

if [ ! -d ${NOTE} ]
	then
   	touch ${NOTE}
fi
#------------------------------------------------------------------

#STAGE 1 - COREGISTER FRAMES TO 1ST FRAME OF RAW IMAGE

#------------------------------------------------------------------

# Clear directory of everything besides timepoints scans to prevent repeats
cd ${DIROUT}; find . -type f ! -name "*BL*" -delete 2> /dev/null;

files=(${PET}/${subj}/*);

if [ ${#files[@]} > 1 ]; then
    echo "Following PET DYNAMIC IMAGE protocol from: http://adni.loni.usc.edu/methods/pet-analysis-method/pet-analysis/#pet-pre-processing-container"
 
    init=1;
    iter=1;
    
    for blin in ${DIROUT}/*BL*; do
        echo ${blin}; 
        echo ${iter}
        # flirt -in imageX -ref image1 -dof 12 -out imageXout -omat imageXtoimage1.mat
        cmd="${FSLFLIRT} \
             -in ${blin} \
             -ref ${DIROUT}/${subj}_TAUPET_BL${init}.nii \
             -dof 12
             -out ${DIROUT}/${subj}_${iter}out.nii.gz \
             -omat ${DIROUT}/${subj}_1to${iter}.xfm \
             -datatype float"
        eval ${cmd}
        echo -e "STAGE: 1.5 STEP 1 --> ${subj} COREGISTER SCAN #${iter} to 1st EXTRACTED FRAME \r\n" >> ${NOTE}
 
        ((iter+=1));
    done

    # Create timepoints directory if does not exist

    if [ ! -d ${timepoints} ]; then
        mkdir -p ${timepoints}
    fi

else
    echo "No scans to co-register chief"
    #break
fi

# Organize 
mv ${DIROUT}/*.xfm* ${timepoints};
mv ${DIROUT}/*out* ${timepoints};

cd ${DIROUT}; chmod 775 *
cd ${project_conf}
chmod 775 *
done
