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
aws_deploy::s3::bucket { "create bucket":
  ensure      => 'present',
  region      => 'ap-southeast-1',
  bucket_name => 'test-1308073.2016.04.22',
}
->
aws_deploy::s3::bucket { "delete bucket":
  ensure      => 'absent',
  region      => 'ap-southeast-1',
  bucket_name => 'test-1308073.2016.04.22',
}