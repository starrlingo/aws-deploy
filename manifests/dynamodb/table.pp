# Definition: aws_deploy::cloudwatch::alarm
#
# This definition manage AWS Cloudwatch alarm and alarm action
#
# Parameters:
# - ensure: 'present', 'absent' are allowed
# - region: AWS region
# - table_name: The descriptive name for the table
# - hash_attribute_name: The name of hash key attribute
# - hash_attribute_type: Valid type are "S", "N" and "B"
# - range_attribute_name: The name of range key attribute
# - range_attribute_type: Valid type are "S", "N" and "B"
# - read_capacity_units: The provisioned throughput for read capacity units
# - write_capacity_units: The provisioned throughput for write capacity units
# Requires: None
#
# Sample Usage:
# aws_deploy::dynamodb::table { "create test table":
#   ensure => 'present',
#   region => 'us-west-2',
#   table_name => 'test',
#   hash_attribute_name => 'time',
#   hash_attribute_type => 'S',
#   range_attribute_name => 'message',
#   range_attribute_type => 'S',
#   read_capacity_units  => 1,
#   write_capacity_units => 1,
# }
#  
define aws_deploy::dynamodb::table (
  $ensure,
  $region,
  $table_name,
  $hash_attribute_name  = undef,
  $hash_attribute_type  = undef,
  $range_attribute_name = undef,
  $range_attribute_type = undef,
  $read_capacity_units  = 5,
  $write_capacity_units = 5,
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)

  case $ensure {
    'present': {
      # check attribute type
      $valid_attribute_types = [ 'S', 'N', 'B' ]
      validate_re($hash_attribute_type, $valid_attribute_types)

      # deploy table
      if $range_attribute_name and $range_attribute_type {
        validate_re($range_attribute_type, $valid_attribute_types)
        exec { "deploy dynamoDB table ${table_name}":
          command => "aws dynamodb create-table --table-name ${table_name} \
                      --attribute-definitions \
                      AttributeName=${hash_attribute_name},AttributeType=${hash_attribute_type} \
                      AttributeName=${range_attribute_name},AttributeType=${range_attribute_type} \
                      --key-schema AttributeName=${hash_attribute_name},KeyType=HASH AttributeName=${range_attribute_name},KeyType=RANGE \
                      --provisioned-throughput ReadCapacityUnits=${read_capacity_units},WriteCapacityUnits=${write_capacity_units} \
                      --region ${region}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
          onlyif  => "/bin/true && ! aws dynamodb describe-table \
                      --table-name ${table_name} --region ${region}"
        }
      } else {  
        exec { "deploy dynamoDB table ${table_name}":
          command => "aws dynamodb create-table --table-name ${table_name} \
                      --attribute-definitions \
                      AttributeName=${hash_attribute_name},AttributeType=${hash_attribute_type} \
                      --key-schema AttributeName=${hash_attribute_name},KeyType=HASH \
                      --provisioned-throughput ReadCapacityUnits=${read_capacity_units},WriteCapacityUnits=${write_capacity_units} \
                      --region ${region}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
          onlyif  => "/bin/true && ! aws dynamodb describe-table \
                      --table-name ${table_name} --region ${region}"
        }
      }
    }
    'absent': {
      exec { "delete dynamoDB table ${table_name}":
        command => "aws dynamodb --region ${region} delete-table \
                    --table-name ${table_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
    }
    default: {
      fail("${ensure} is not supported")
    }
  }
}