# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://docs.puppetlabs.com/guides/tests_smoke.html
#
# alarm creation/delete testing
aws_deploy::cloudwatch::alarm { 'Create DynamoDB test alarm':
  ensure               => 'present',
  region               => 'us-west-2',
  accountId            => '326220766626',
  alarm_name           => 'High ConsumedWriteCapacity alarm',
  metric_name          => 'ConsumedWriteCapacityUnits',
  namespace            => 'AWS/DynamoDB',
  dimension_name       => 'TableName',
  dimension_value      => 'test',
  statistic            => 'Sum',
  period               => 300,
  evaluation_periods   => 6,
  comparison_operator  => 'GreaterThanOrEqualToThreshold',
  threshold            => 10,
  alarm_sns_topic_name => 'test-cloudwatch-alarm',
}
->
aws_deploy::cloudwatch::alarm { 'Delete DynamoDB test alarm':
  ensure               => 'absent',
  region               => 'us-west-2',
  accountId            => '326220766626',
  alarm_name           => 'High ConsumedWriteCapacity alarm',
  alarm_sns_topic_name => 'test-cloudwatch-alarm',
}
