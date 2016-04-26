# Definition: aws_deploy::iam::role
#
# This definition manage AWS IAM role
#
# Parameters:
# - ensure: 'present', 'absent' are allowed
# - role_name: role name
# - assume_policy_document_path: File path of assume role policy
# - policy_document_path: File path of role policy
# - path: The path to the role
# Requires: None
#
# Sample Usage:
# aws_deploy::iam::role { 'create test IAM role':
#   ensure                      => 'present',
#   role_name                   => 'test',
#   assume_policy_document_path => '/tmp/iam_assume_test_role_policy.json',
#   policy_document_path        => '/tmp/iam_test_role_policy.json',
# }
#
define aws_deploy::iam::role (
  $ensure,
  $role_name,
  $assume_policy_document_path = undef,
  $policy_document_path        = undef,
  $path                        = '/',
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)

  case $ensure {
    'present': {
      exec { "deploy ${role_name} role":
        command => "aws iam create-role --role-name ${role_name} --assume-role-policy-document file://${assume_policy_document_path} --path ${path}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && ! aws iam list-roles --path-prefix ${path} \
                    | grep \'role${path}${role_name}\\\"$\'",
      }
      ->
      exec { "update ${role_name} assume role policy":
        command => "aws iam update-assume-role-policy --role-name ${role_name} --policy-document file://${assume_policy_document_path}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
      ->
      exec { "update ${role_name} role policy":
        command => "aws iam put-role-policy --role-name ${role_name} \
                    --policy-name ${role_name} --policy-document file://${policy_document_path}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
    }
    'absent': {
      # delete role
      exec { "delete ${role_name} role policy":
        command => "aws iam delete-role-policy --role-name ${role_name} \
                    --policy-name ${role_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
      ->
      exec { "delete ${role_name} role":
        command => "aws iam delete-role --role-name ${role_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
    }
    default: {
      fail("${ensure} is not supported")
    }
  }
}