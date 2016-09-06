# aws_deploy

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with aws_deploy](#setup)
    * [Requirements](#setup-requirements)
    * [Installing aws_deploy](#installing-aws_deploy)
3. [Usage - Configuration options and additional functionality](#usage)
  * [Managing IAM role](#managing-iam-role)
  * [Managing Lambda](#managing-lambda)
  * [Managing DynamoDB](#managing-dynamodb)
  * [Managing S3 Bucket](#managing-s3-bucket)
  * [Managing S3 Files](#managing-s3-files)
  * [Managing Cloudwatch alarm](#managing-cloudwatch-alarm)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

It's annoying to manage your AWS services in Console or CLI when the architecture are complex. 
This Puppet module allows you to manage & deploy AWS services in a simple way.

## Setup

### Setup Requirements

* Puppet 3.4 or greater
* AWS CLI

### Installing aws_deploy

1. Install AWS CLI (This step can be skipped if you are in Amazon Linux AMI)
  
  Install with following commands in Linux

  ~~~
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  unzip awscli-bundle.zip
  sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  ~~~
2. Configure AWS Credential (This step can be skipped if you runs in AWS EC2 environment and associated EC2 with IAM role)
  
  Place the credentials in a file at ~/.aws/credentials based on the following template:

  ~~~
  [default]
  aws_access_key_id = <your_access_key_id>
  aws_secret_access_key = <your_secret_access_key>
  ~~~
Note: For security concern, it's not recommended to setup AWS credential in local. 
You should launch an EC2 instance (associated with IAM role) to access another AWS services.
3. Install Puppet

  ~~~
  yum install puppet
  ~~~
  
4. Install Puppet aws_deploy module
  
  ~~~
  puppet module install jasonxlin-aws_deploy
  ~~~
  
## Usage
### Managing IAM role
Create IAM role
~~~
aws_deploy::iam::role { 'description of role':
  ensure                      => 'present',
  role_name                   => 'name-of-role',
  assume_policy_document_path => '/path/your-assume-policy.json',
  policy_document_path        => '/path/your-role-policy.json',
}
~~~
Delete IAM role
~~~
aws_deploy::iam::role { 'description of role':
  ensure                      => 'absent',
  role_name                   => 'name-of-role',
}
~~~

### Managing Lambda
Create Lambda
~~~
aws_deploy::lambda::function { "description of function":
  ensure => 'present',
  region => 'us-west-2',
  timeout => '180',
  memory => '128',
  function_name => "name-of-function",
  exec_role_arn => "arn:aws:iam::${myaccountId}:role/my_lambda_exec_role",
  zip_file_path => "/path/test.zip",
}
~~~
Delete Lambda
~~~
aws_deploy::lambda::function { "description of function":
  ensure => 'absent',
  region => 'us-west-2',
  function_name => "name-of-function",
}
~~~

### Managing DynamoDB
Create table
~~~
aws_deploy::dynamodb::table { "description of dynamodb table":
  ensure => 'present',
  region => 'us-west-2',
  table_name => 'test',
  hash_attribute_name => 'your hash key name',
  hash_attribute_type => 'S/N/B',
  range_attribute_name => 'your range key name',
  range_attribute_type => 'S/N/B',
  read_capacity_units  => 1,
  write_capacity_units => 1,
}
~~~
Delete table
~~~
aws_deploy::dynamodb::table { "description of dynamodb table":
  ensure => 'absent',
  region => 'us-west-2',
  table_name => 'test',
}
~~~

### Managing S3 Bucket
Create S3 bucket
~~~
aws_deploy::s3::bucket { "description of bucket":
  ensure      => 'present',
  region      => 'ap-southeast-1',
  bucket_name => 'your bucket name',
}
~~~
Delete S3 bucket
~~~
aws_deploy::s3::bucket { "description of bucket":
  ensure      => 'absent',
  region      => 'ap-southeast-1',
  bucket_name => 'your bucket name',
}
~~~

### Managing S3 Files
Upload S3 files
~~~
aws_deploy::s3::files { "description of s3 files":
  ensure      => 'file/directory',
  region      => 'your bucket region',
  source      => "your file path in S3 or local",
  destination => "your file path in S3 or local",
}
~~~
Delete S3 files
~~~
aws_deploy::s3::files { "description of s3 files":
  ensure      => 'absent',
  region      => 'your bucket region',
  source      => "your file path in S3 or local",
}
~~~

### Managing Cloudwatch alarm
Create alarm
~~~
aws_deploy::cloudwatch::alarm { "description of cloudwatch alarm":
  ensure               => 'present',
  region               => 'your deployed region',
  accountId            => 'your account id',
  alarm_name           => "your alarm name",
  metric_name          => "metric name in cloudwatch",
  namespace            => "metric namespace in cloudwatch",
  dimension_name       => "dimension name",
  dimension_value      => "dimension value",
  statistic            => "Sum/Maximum/Minimum/Average",
  period               => 300,
  evaluation_periods   => 6,
  comparison_operator  => "GreaterThanOrEqualToThreshold/GreaterThanThreshold/LessThanThreshold/LessThanOrEqualToThreshold",
  threshold            => 10,
  alarm_sns_topic_name => "sns topic name",
}
~~~
Delete alarm
~~~
aws_deploy::cloudwatch::alarm { "description of cloudwatch alarm":
  ensure               => 'absent',
  region               => 'your deployed region',
  accountId            => 'your account id',
  alarm_name           => "your alarm name",
}
~~~

## Reference


## Limitations
Only IAM roles, Lambda, Cloudwatch alarm, SQS, S3 resources are supported now.

## Development

Fork this module from git repo (https://github.com/starrlingo/aws-deploy).
