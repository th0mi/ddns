#!/bin/bash
# Script retrieves the current IP Address from a standard German Telecom Router and
# uses this to update an Amazon AWS Route 53 zone
CURL="/usr/bin/curl -ks"
TMPFILE=/tmp/`date +%Y%m%d_%H%M%S`.awsdns
AWSBIN=/usr/local/bin/aws

#URL to the router page containing the current IP
URL="https://<YOUR ROUTER IP HERE>/top_status.stm"
# Amazon AWS hosted zone ID
ZONEID=<YOUR ZONEID HERE>
# A record for your dyndns name
DYNHOST=<YOUR HOSTNAME HERE>

# a public name server to check what the currently registered IP is
DNS=8.8.8.8

# GET IP FROM ROUTER
IP=$(${CURL} $URL | grep "var wan_ip" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

# FIND CURRENTLY REGISTERED IP
REMOTEIP=`dig +short $DYNHOST @$DNS`

if [ "$REMOTEIP" == "$IP" -o "$REMOTEIP" == "" ]
then
   echo "$IP still current" > /dev/null
else
   echo "we need to update"
   #CREATE AWS UPDATE RECORD
   cat <<UPDATE-JSON > $TMPFILE
   {
     "Comment": "dyndns",
     "Changes": [
       {
         "Action": "UPSERT",
         "ResourceRecordSet": {
           "Name": "$DYNHOST",
           "Type": "A",
           "TTL": 300,
           "ResourceRecords": [
             {
               "Value": "$IP"
             }
           ]
         }
       }
     ]
   }
UPDATE-JSON
   echo "Updating IP to $IP"
   # do the update via AWS cli
   ${AWSBIN} route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://$TMPFILE
   rm $TMPFILE
fi
