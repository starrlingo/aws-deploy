# Definition: aws_deploy::s3::files
#
# This definition upload/download S3 files 
# which also support access by assume role
#
# Parameters:
# - $ensure: 'present', 'absent' are allowed
# - $region: AWS region
# - $bucket_name: Bucket name must be unique around world
# - $website_index_html: Website hosting index html path
# - $website_error_html: Website hosting error html path
# - $access_key_id: AWS credential key
# - $secret_access_key: AWS credential key
#
# Requires: None
#
# Sample Usage:
# aws_deploy::s3::files { "update file to S3 bucket":
#   ensure      => 'file',
#   source      => "/home/test.txt",
#   destination => "s3://your_bucket_name",
# }
#
define aws_deploy::s3::files (
  $ensure,
  $source,
  $destination         = undef,
  $region              = 'us-west-2',
  $assume_iam_role_arn = undef,
  $access_key_id       = undef,
  $secret_access_key   = undef,
){
  case $ensure {
    'directory', 'file': {
      if $ensure == 'directory' {
        $action = 'sync'
      } else {
        $action = 'cp'
      }
      if $assume_iam_role_arn {
        exec {"manage s3 file from ${source} to ${destination} by assume role":
          command => "/bin/true && AWS_OUTPUT=\"\$(/usr/bin/aws sts \
                      assume-role --role-arn \"${assume_iam_role_arn}\" \
                      --role-session-name \"s3-assume-role-access\")\" \
                      && export AWS_ACCESS_KEY_ID=$(echo \"\$AWS_OUTPUT\" \
                      | grep -oP \"(?<=\\\"AccessKeyId\\\": \\\")[^\\\"]+\") \
                      && export AWS_SECRET_ACCESS_KEY=$(echo \"\$AWS_OUTPUT\" \
                      | grep -oP \"(?<=\\\"SecretAccessKey\\\": \\\")[^\\\"]+\") \
                      && export AWS_SESSION_TOKEN=$(echo \"\$AWS_OUTPUT\" \
                      | grep -oP \"(?<=\\\"SessionToken\\\": \\\")[^\\\"]+\") \
                      && /usr/bin/aws s3 ${action} ${source} ${destination} \
                      --exact-timestamps --region ${region}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
          timeout => 86400,
        }
      }
      # move s3 file by build-in role
      if !$access_key_id and !$secret_access_key and !$assume_iam_role_arn {
        exec { "move s3 file from ${source} to ${destination} by build-in role":
          command => "aws s3 ${action} ${source} ${destination} \
                      --region ${region}",
          path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        }
      }
      # move s3 file by AWS credential - TBD
    }
    'absent': {
      # delete file from S3
      exec { "delete ${source}":
        command => "aws s3 rm ${source} --region ${region} || aws s3 rm ${source} --recursive --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }      
    }
    default: {
      fail("${ensure} is not supported on aws_deply::s3::files")
    }
  }
}