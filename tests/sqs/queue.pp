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
# sqs creation testing
$accountId = generate("/bin/sh", "-c", "curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep accountId | grep -o [0-9]* | xargs echo -n")

file { "/tmp/sqs_attrubutes.json":
  ensure => "file",
  mode => "0600",
  content => '{ "VisibilityTimeout": "270" }',
}
->
aws_deploy::sqs::queue { 'create test SQS queue':
  ensure                  => 'present',
  region                  => 'us-west-2',
  queue_name              => 'test',
  accountId               => $accountId,
  attribute_document_path => '/tmp/sqs_attrubutes.json',
}
->
aws_deploy::sqs::queue { 'delete test SQS queue':
  ensure                  => 'absent',
  region                  => 'us-west-2',
  queue_name              => 'test',
  accountId               => $accountId,
}