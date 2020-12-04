
utils_setup_config() {
     if  [ -e ${1} ]; then
       source ${1}
     else
       echo "Configuration file ${1} not found. :( Aborting"
       exit 1
     fi
	
	readarray SUBJECT < ${subjectlist}
	readarray reference < ${referencereg}
	readarray regionsofinterest < ${regionsofinterest}
    readarray FScerebellum < ${FScerebellum}
    readarray weightedroi < ${weightedroi}
}

utils_SGE_TASK_ID_SUBJ(){

    if [ "$SGE_TASK_ID" == "" ]; then
	echo "SGE_TASK_ID not set. Aborting."
	exit 1
    fi
     SUBJECT=(${SUBJECT[@]})
     idx=$((SGE_TASK_ID - 1))
     nsubj=${#SUBJECT[@]}
     subj=${SUBJECT[${idx}]}
     
}
