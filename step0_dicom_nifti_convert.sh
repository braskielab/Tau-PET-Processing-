#!/bin/bash
#$ -cwd

#$ -q compute.q

# Convert DICOM to nifti
# To run: "./dicom_nifti_convert.sh petproc.config"
# -----------------------------------------------------

if [ "$SGE_TASK_ID" == "" ]
then

 CONFIG=${1}
 SGE_TASK_ID=1

fi
# CONFIG - petproc.config
source utils.sh

utils_setup_config ${CONFIG}

# -----------------------------------------------------

for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}

iter=0;

# Navigate to folder with .dcm files --> convert to nifti

if [ ! -d ${DIROUT} ]
    then
    mkdir -p ${DIROUT}
fi


    for dir in ${DIRIN}; do
    echo $dir
    
    # Clear directory of repeats
    rm $dir/*.nii* 2> /dev/null;
    
    #Call mricron conversion program, pass in directory containing dcm files
    cmd="/usr/local/dcm2niix-master/build/bin/dcm2niix -o $dir  $dir/I*"
    eval ${cmd}
    echo "${cmd}:  CONVERTED ${subj} DICOM --> NIFTI"
   
    echo ${iter}  
    ((iter+=1));
    mv $dir/*.nii* ${subj}_TAUPET_BL${iter}.nii.gz; mv *.nii.gz* ${DIROUT}; 
    done

cd ${DIROUT}
chmod 775 *

cd ${project_conf}
unset iter;
done

