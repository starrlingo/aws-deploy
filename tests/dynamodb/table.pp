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
aws_deploy::dynamodb::table { 'create test table':
  ensure               => 'present',
  region               => 'us-west-2',
  table_name           => 'test',
  hash_attribute_name  => 'time',
  hash_attribute_type  => 'S',
  range_attribute_name => 'message',
  range_attribute_type => 'S',
  read_capacity_units  => 1,
  write_capacity_units => 1,
}
->
aws_deploy::dynamodb::table { 'delete test table':
  ensure     => 'absent',
  region     => 'us-west-2',
  table_name => 'test',
}