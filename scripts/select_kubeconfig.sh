#!/usr/bin/env bash

# Script to select the correct kubeconfig file to use for the current context

PS3="Select the KUBECONFIG you want: "

CONFIG_FILE=""
CONFIG_DIR="/Users/mzottner/.decc"
VALID=FALSE
OPTION="${1}"

function select_config() {
	case ${1} in
	1)
		CONFIG_FILE="gitlab-runner.yaml"
		ALTERNATE_CONFIG_FILE="lyra-appmod-builder.yaml"
		VALID=TRUE
		;;
	2)
		CONFIG_FILE="production.yaml"
		ALTERNATE_CONFIG_FILE="vela-tanzu.yaml"
		VALID=TRUE
		;;
	3)
		CONFIG_FILE="cnfe-docs.yaml"
		ALTERNATE_CONFIG_FILE="sdc1-staging-mapbu-cnfe-docs.yaml"
		VALID=TRUE
		;;
	4)
		CONFIG_FILE="test.yaml"
		ALTERNATE_CONFIG_FILE="ara-appmod.yaml"
		VALID=TRUE
		;;
	0 | 5)
		export KUBECONFIG=""
		echo "KUBECONFIG reset"
		VALID=TRUE
		;;
	*)
		echo "Invalid option: $REPLY"
		;;
	esac
}

function main() {
	if [ ! -z "${OPTION}" ]; then
		select_config ${OPTION}
	fi

	if [[ "${VALID}" == "FALSE" ]]; then
		select OPTION in gitlab prod cnfe test local; do
			#echo "Selected character: $OPTION"
			#echo "Selected number: $REPLY"
			select_config ${REPLY}
			if [[ "$VALID" == "TRUE" ]]; then
				break
			fi
		done
	fi

	if [ ! -z "${CONFIG_FILE}" ]; then
		export KUBECONFIG="${CONFIG_DIR}/${CONFIG_FILE}"
		echo "KUBECONFIG=${KUBECONFIG}  [${ALTERNATE_CONFIG_FILE}]"
	fi
}

main
