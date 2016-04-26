# Definition: aws_deploy::sqs::queue
#
# This definition manage AWS SQS
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
#
define aws_deploy::sqs::queue (
  $ensure,
  $region,
  $queue_name,
  $account_id,
  $attribute_document_path = undef,
  $permission_document_path = undef,
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)

  case $ensure {
    'present': {
      exec { "deploy sqs ${queue_name} in ${region}":
        command => "aws sqs create-queue --region ${region}\
                    --queue-name ${queue_name} ",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }

      # set queue attribute
      if $attribute_document_path {
        exec { "set sqs ${queue_name} attributes in ${region}":
          command => "aws sqs --region ${region} set-queue-attributes --queue-url https://sqs.${region}.amazonaws.com/${account_id}/${queue_name} --attributes file://${attribute_document_path}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
          require => Exec["deploy sqs ${queue_name} in ${region}"],
        }
      }

      # set queue permission
      if $permission_document_path {
        exec { "set sqs ${queue_name} permission policy":
          command => "aws sqs --region ${region} set-queue-attributes --queue-url https://sqs.${region}.amazonaws.com/${account_id}/${queue_name} --attributes file://${permission_document_path}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
          require => Exec["deploy sqs ${queue_name} in ${region}"],
        }
      }
    }
    'absent': {
      # delete sqs
      exec { "delete sqs ${queue_name} in ${region}":
        command => "aws sqs delete-queue --region ${region} --queue-url  https://sqs.${region}.amazonaws.com/${account_id}/${queue_name}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && aws sqs get-queue-url --region ${region} \
                    --queue-name ${queue_name} ",
      }
    }
    default: {
      fail("${ensure} is not supported")
    }
  }
}