# ec2spot.com

public serverless API to query AWS EC2 spot prices

## Endpoint

https://ec2spot.com

(100% serverless with CloudFront, Route53, API Gateway and Lambda)



## Usage

### query current spot price of c4.large in us-west-2

```
$ curl  -s https://ec2spot.com/current-spot-price/us-west-2/Linux/c4.large | json_pp
```

response:

```
{
   "data" : {
      "NextToken" : "",
      "SpotPriceHistory" : [
         {
            "InstanceType" : "c4.large",
            "ProductDescription" : "Linux/UNIX",
            "Timestamp" : "2016-08-14T11:35:47.000Z",
            "SpotPrice" : "0.031500",
            "AvailabilityZone" : "us-west-2a"
         },
         {
            "SpotPrice" : "0.030200",
            "AvailabilityZone" : "us-west-2b",
            "ProductDescription" : "Linux/UNIX",
            "Timestamp" : "2016-08-14T11:33:02.000Z",
            "InstanceType" : "c4.large"
         },
         {
            "InstanceType" : "c4.large",
            "AvailabilityZone" : "us-west-2c",
            "SpotPrice" : "0.019300",
            "ProductDescription" : "Linux/UNIX",
            "Timestamp" : "2016-08-14T11:32:10.000Z"
         }
      ]
   }
}
```



### return the AZ of lowest price of c4.large in us-west-2



just add `?return_lowest_az=1` as the argument

```
$ curl  -s https://ec2spot.com/current-spot-price/us-west-2/Linux/c4.large?return_lowest_az=1| json_pp
```

response:

```
{
   "data" : "us-west-2c"
}
```



## Response Cache

Please note the service comes with CloudFront with 30s TTL cache expiration time. Some requests may take longer time than usual when cache expires. 

