#!/bin/bash
echo ECS_CLUSTER=CNE1DEVBSD-ECS-CLUSTER >> /etc/ecs/ecs.config
yum -y install aws-cli && mkdir /opt/app-certs/efpv2 -p
mkdir /opt/rsa/qa -p && mkdir /opt/rsa/stg -p
aws s3 cp s3://efpv2-certs-staging/ /opt/app-certs/efpv2/ --recursive --region cn-north-1
aws s3 cp s3://sis-jwt-qa/ /opt/rsa/qa/ --recursive --region cn-north-1
aws s3 cp s3://sis-jwt-stg/ /opt/rsa/stg/ --recursive --region cn-north-1
