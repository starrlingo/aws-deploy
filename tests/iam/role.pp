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
# role creation testing
file { "/tmp/iam_assume_test_role_policy.json":
  ensure => "file",
  mode => "0600",
  content => '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }',
}
->
file { "/tmp/iam_test_role_policy.json":
  ensure => "file",
  mode => "0600",
  content => '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:List*"],
        "Resource": ["*"]
      }
    ]
  }',
}
->
aws_deploy::iam::role { 'create test IAM role':
  ensure                      => 'present',
  role_name                   => 'test',
  assume_policy_document_path => '/tmp/iam_assume_test_role_policy.json',
  policy_document_path        => '/tmp/iam_test_role_policy.json',
}
->
aws_deploy::iam::role { 'delete test IAM role':
  ensure    => 'absent',
  role_name => 'test',
}