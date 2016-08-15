#!/bin/bash

az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=${az%%?}
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

logfile='/tmp/termination-time.out'

sns_arn=${ARN-undefined_arn}
sns_subject=${SUBJECT-"spot instance is terminating"}


message="{\"instanceId\": \"${instance_id}\", \"region\":\"${region}\"}"


polling() {

        http_code=$(curl -s http://169.254.169.254/latest/meta-data/spot/termination-time -w "%{http_code}\n" -o $logfile)

        if [[ $http_code != "404" ]]; then
                return 0
        else
                return 1
        fi
        return false
}

notify() {
	echo "spot instanceId: ${instance_id} in region: ${region} is terminating now"
	aws sns  --region $region publish --subject "$sns_subject" --message "$message" --topic-arn $sns_arn
}


while true
do
  polling && echo "got signal" && cat $logfile && notify && break
  sleep 5
done

exit 0
