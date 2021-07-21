#!/bin/bash

#CME Helper Script for Auto Scale Automation

DEBUG=false
LOG="/var/log/cme_helper.log"

. /etc/profile.d/CP.sh

AUTOPROV_ACTION=$1
GW_NAME=$2

echo "[ $(date +"%T")] Command: $@" >> $LOG

if [[ $AUTOPROV_ACTION == add ]]
then

    SID=$(mgmt_cli -r true login -f json | jq -r '.sid')
    GW_JSON=$(mgmt_cli --session-id $SID show simple-gateway name $GW_NAME -f json)
    if [ $DEBUG = true ]; then echo "[ DEBUG ] $GW_JSON" >> $LOG;fi
    GW_UID=$(echo $GW_JSON | jq '.uid')

	echo "[ $(date +"%T") $GW_NAME ] - Setting IDA session limit to 200k and push policy to $GW_NAME" >> $LOG
    JSON_OUTPUT=$(mgmt_cli --session-id $SID set-generic-object uid $GW_UID identityAwareBlade.iaMaxEnforcedIdentities 200000 identityAwareBlade.iaMaxAuthenticatedUsers 200000 -f json)
    if [ $DEBUG = true ]; then echo "[ DEBUG ] $JSON_OUTPUT" >> $LOG;fi

    echo "[ $(date +"%T") $GW_NAME ] - Setting Content Awareness Blade"  >> $LOG
    JSON_OUTPUT=$(mgmt_cli --session-id $SID set simple-gateway name $GW_NAME content-awareness true -f json)
    if [ $DEBUG = true ]; then echo "[ DEBUG ] $JSON_OUTPUT" >> $LOG;fi

    echo "[ $(date +"%T") $GW_NAME ] - Publishing Session"  >> $LOG
    JSON_OUTPUT=$(mgmt_cli publish --session-id $SID -f json)
    if [ $DEBUG = true ]; then echo "[ DEBUG ] $JSON_OUTPUT" >> $LOG;fi

    echo "[ $(date +"%T") $GW_NAME ] - Getting Policy Pacakge name for Gateway $GW_NAME"  >> $LOG
    PACKAGE=$(mgmt_cli --session-id $SID show-gateways-and-servers details-level full -f json |jq --arg GWNAME "$GW_NAME" '.objects[] |select(.name==$GWNAME) | .policy."access-policy-name"')

    echo "[ $(date +"%T") $GW_NAME ] - Package Name: $PACKAGE"  >> $LOG
    echo "[ $(date +"%T") $GW_NAME ] - Installing $PACKAGE on $GW_NAME"  >> $LOG
    JSON_OUTPUT=$(mgmt_cli --session-id $SID install-policy targets $GW_NAME policy-package $PACKAGE -f json)
    if [ $DEBUG = true ]; then echo "[ DEBUG ] $JSON_OUTPUT" >> $LOG;fi

    exit 0
fi
