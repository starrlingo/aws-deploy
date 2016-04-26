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
aws_deploy::s3::files { "update file to S3 bucket":
  ensure      => 'file',
  region      => 'ap-southeast-1',
  source      => "/home/test.txt",
  destination => "s3://test-1308073.2016.04.22",
}
->
aws_deploy::s3::files { "delete file from S3 bucket":
  ensure      => 'absent',
  region      => 'ap-southeast-1',
  source      => "s3://test-1308073.2016.04.22/test.txt",
}