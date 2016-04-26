# Definition: aws_deploy::cloudwatch::alarm
#
# This definition manage AWS Cloudwatch alarm and alarm action
#
# Parameters:
# - ensure: 'present', 'absent' are allowed
# - region: AWS region
# - alarm_name: The descriptive name for the alarm
# - metric_name: The name for the alarm's associated metric
# - namespace: The namespace for the alarm's associated metric
# - dimension_name: The dimensions name for the alarm's associated metric
# - dimension_value: The dimensions value for the alarm's associated metric
# - statistic: The statistic apply to alarm's associated metric, such as "Sum"
# - period: The period in seconds over which the specified statistic is applied
# - evaluation_periods: The number of periods which compared to the threshold
# - comparison_operator: The arithmetic operation to use when comparing the specified statistic and threshold
# - threshold: The value against which the specified statistic is compared
# - alarm_sns_topic_name: The SNS to execute when alarm transitions into ALARM state
#
# Requires: None
#
# Sample Usage:
# aws_deploy::cloudwatch::alarm { "Create test ConsumedWriteCapacity alarm":
#   ensure               => 'present',
#   region               => 'us-west-2',
#   accountId            => '<your account id>',
#   alarm_name           => "High ConsumedWriteCapacity alarm for test",
#   metric_name          => "ConsumedWriteCapacityUnits",
#   namespace            => "AWS/DynamoDB",
#   dimension_name       => "TableName",
#   dimension_value      => "test",
#   statistic            => "Sum",
#   period               => 300,
#   evaluation_periods   => 6,
#   comparison_operator  => "GreaterThanOrEqualToThreshold",
#   threshold            => 10,
#   alarm_sns_topic_name => "test-cloudwatch-alarm",
# }
#  
define aws_deploy::cloudwatch::alarm (
  $ensure,
  $region,
  $alarm_name,
  $alarm_sns_topic_name,
  $account_id,
  $metric_name         = undef,
  $namespace           = undef,
  $dimension_name      = undef,
  $dimension_value     = undef,
  $statistic           = undef,
  $period              = undef,
  $evaluation_periods  = undef,
  $comparison_operator = undef,
  $threshold           = undef,
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)

  case $ensure {
    'present': {
      exec { "deploy alarm SNS for ${alarm_name} in ${region}":
        command => "aws sns create-topic --name ${alarm_sns_topic_name} \
                    --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && ! aws sns get-topic-attributes \
                    --region ${region} \
                    --topic-arn \"arn:aws:sns:${region}:${account_id}:${alarm_sns_topic_name}\""
      }

      # deploy cloudwatch alarm
      exec { "deploy alarm for ${alarm_name} in ${region}":
        command => "aws cloudwatch put-metric-alarm --region ${region} \
                    --alarm-name \"${alarm_name}\" \
                    --metric-name ${metric_name} \
                    --dimensions \
                    Name=${dimension_name},Value=${dimension_value} \
                    --statistic ${statistic} --period ${period} \
                    --namespace ${namespace} \
                    --evaluation-periods ${evaluation_periods} \
                    --threshold ${threshold} \
                    --comparison-operator ${comparison_operator} \
                    --alarm-actions arn:aws:sns:${region}:${account_id}:${alarm_sns_topic_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        require => Exec["deploy alarm SNS for ${alarm_name} in ${region}"],
      }
    }
    'absent': {
      # delete alarm SNS & alarm
      exec { "delete alarm SNS for ${alarm_name} in ${region}":
        command => "aws sns delete-topic --region ${region} \
                    --topic-arn arn:aws:sns:${region}:${account_id}:${alarm_sns_topic_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
      ->
      exec { "delete cloudwatch alarm for ${alarm_name} in ${region}":
        command => "aws cloudwatch delete-alarms --region ${region} \
                    --alarm-name \"${alarm_name}\"",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
    }
    default: {
      fail("${ensure} is not supported")
    }
  }
}