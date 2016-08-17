#!/bin/bash
#
# deregister current ec2 instance id from all registered ELBs
# execute this script locally or 
# $ curl -s https://metapolling.ec2spot.com/deregister_from_elb.sh | sh
#
# by pahudnet@gmail.com 2016.08.17
#
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=${az%%?}

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

do_dereg_from_elb

exit 0