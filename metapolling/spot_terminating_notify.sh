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

        if [[ $http_code == "200" ]]; then
                return 0
        else
                return 1
        fi
        return 1
}

notify() {
	echo "spot instanceId: ${instance_id} in region: ${region} is terminating now"
	aws sns  --region $region publish --subject "$sns_subject" --message "$message" --topic-arn $sns_arn
}

list_elb(){
        aws --region $region elb describe-load-balancers --query \
        "LoadBalancerDescriptions[?Instances[?InstanceId=='${1}']].LoadBalancerName"
}


dereg_from_elb() {
        echo "deregister ${1} from ${2}"
        aws --region $region elb deregister-instances-from-load-balancer --instances "$1" --load-balancer-name "$2" > /dev/null
}

do_dereg_from_elb() {
  list_elb ${instance_id} | sed -ne 's/"\(.*\)".*/\1/p' | while read elb
  do
   dereg_from_elb $instance_id $elb
  done
}



while true
do
  polling && echo "got signal" && cat $logfile && notify && \
  do_dereg_from_elb && break
  sleep 5
done

exit 0
