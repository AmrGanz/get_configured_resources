file="temp_`date +%Y-%m-%d_%H:%M:%S`"

if [ "$1" == "--all" ]; then
	echo -e "Generating the required data from all of the namespaces, it will take some time...\n"
	#Get projects names
	projName=`oc get projects  -o jsonpath="{range .items[*].metadata}{.name}{'\n'}" | sed '/^[[:space:]]*$/d'`

	#Get Projects count
	projCount=`oc get projects  --no-headers -o name | wc -l`

	# Initiate a file with the following header
	echo  'Namespace Type Name ContainerName RequestCPU RequestMEM LimitCPU LimitMEM' > /tmp/$file

	# Loop between projects
	for projName in $projName; do

		# Get Deploymentconfig count
		dcCount=`oc get dc -o name --no-headers -n $projName | wc -l`
		# Get Deployment count
		depCount=`oc get deployment -o name --no-headers -n $projName | wc -l`
		
		# Check if there is a DC resource
		if [ ! -z "$dcCount" ] || [ ! -z "$depCount" ]; then
			# Loop between DC instances
			for (( i=0; i<$dcCount; i++ )); do
				cont=`oc get dc -n $projName -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
				for (( x=0; x<$cont; x++ )); do
					oc get dc -n $projName -o jsonpath="{.items[$i].metadata.namespace} {.items[$i].kind} {.items[$i].metadata.name} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file
				done
			done
		# Loop between Deployment instances
			for (( i=0; i<$depCount; i++ )); do
				cont=`oc get deployment -n $projName -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
				for (( x=0; x<$cont; x++ )); do
					oc get deployment -n $projName -o jsonpath="{.items[$i].metadata.namespace} {.items[$i].kind} {.items[$i].metadata.name} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file
				done
			done
		fi
	done
	cat /tmp/$file | column -t -s " "
			
elif [ "$1" == "--help" ]; then
	echo -e "A script to gather CPU/Memory Requests/Limits values from all Deploymentconfig/Deployment resources\n"
	echo -e "Usage: getResources.sh [OPTION]\n"
	echo -e "Options: \n --help: Show help \n --all: Gather data from all of the namespaces \n <name>: Gather data from specific namespace \n No argument: Gather data from current namespace"

elif [ -z "$1" ]; then
	echo "no project is selected"
	currentProjName=`oc project -q`
	echo -e "Generating the required data for namespace: $currentProjName\n"
	# Get Deploymentconfig count
	dcCount=`oc get dc -o name --no-headers | wc -l`
	# Get Deployment count
	depCount=`oc get deployment -o name --no-headers | wc -l`
	echo -e 'Name Type ContN ReqCPU ReqMEM LimitCPU LimitMEM' > /tmp/$file
		# Check if there is a DC resource
	if [ ! -z "$dcCount" ] || [ ! -z "$depCount" ]; then
		# Loop between DC instances
		for (( i=0; i<$dcCount; i++ )); do
			cont=`oc get dc -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
			for (( x=0; x<$cont; x++ )); do
				oc get dc -o jsonpath="{.items[$i].metadata.name} {.items[$i].kind} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file
			done
		done
		# Loop between Deployment instances
		for (( i=0; i<$depCount; i++ )); do
			cont=`oc get deployment -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
			for (( x=0; x<$cont; x++ )); do
				oc get deployment -o jsonpath="{.items[$i].metadata.name} {.items[$i].kind} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file
			done
		done
	fi
	cat /tmp/$file | column -t -s " "

elif [ ! -z "$1" ] && oc get project $1 &> /dev/null ; then
	echo  'Namespace Type Name ContainerName RequestCPU RequestMEM LimitCPU LimitMEM' > /tmp/$file
	echo -e "Generating the required data for namespace: $1\n"
        # Get Deploymentconfig count
        dcCount=`oc get dc -o name --no-headers -n $1 | wc -l`
        # Get Deployment count
        depCount=`oc get deployment -o name --no-headers -n $1 | wc -l`

        # Check if there is a DC or Deployment resources
        if [ ! -z "$dcCount" ] || [ ! -z "$depCount" ]; then
                # Loop between DC instances
                for (( i=0; i<$dcCount; i++ )); do
                        cont=`oc get dc -n $1 -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
                        for (( x=0; x<$cont; x++ )); do
                                oc get dc -n $1 -o jsonpath="{.items[$i].metadata.namespace} {.items[$i].kind} {.items[$i].metadata.name} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file
                        done
                done
        # Loop between Deployment instances
                for (( i=0; i<$depCount; i++ )); do
                        cont=`oc get deployment -n $1 -o jsonpath="{range .items[$i].spec.template.spec.containers[*]}{.name}{'\n'}" | sed '/^[[:space:]]*$/d' | wc -l`
                        for (( x=0; x<$cont; x++ )); do
                                oc get deployment -n $1 -o jsonpath="{.items[$i].metadata.namespace} {.items[$i].kind} {.items[$i].metadata.name} {.items[$i].spec.template.spec.containers[$x].name} {.items[$i].spec.template.spec.containers[$x].resources.requests.cpu} {.items[$i].spec.template.spec.containers[$x].resources.requests.memory} {.items[$i].spec.template.spec.containers[$x].resources.limits.cpu} {.items[$i].spec.template.spec.containers[$x].resources.limits.memory}{'\n'}" >> /tmp/$file 
                        done
                done
        fi              
        cat /tmp/$file | column -t -s " "

fi
