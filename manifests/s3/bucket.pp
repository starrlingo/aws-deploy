# Definition: aws_deploy::s3::bucket
#
# This definition create or delete a bucket in S3
#
# Parameters:
# - ensure: 'present', 'absent' are allowed
# - region: AWS region
# - bucket_name: Bucket name must be unique around world
# - website_index_html: Website hosting index html path
# - website_error_html: Website hosting error html path
# - access_key_id: AWS credential key
# - secret_access_key: AWS credential key
#
# Requires: None
#
# Sample Usage:
# aws_deploy::s3::bucket { "create bucket":
#   ensure             => 'present',
#   region             => 'ap-southeast-1',
#   bucket_name        => 'your_bucket_name',
# }
#
define aws_deploy::s3::bucket (
  $ensure,
  $bucket_name,
  $region             = 'us-west-2',
  $website_index_html = undef,
  $website_error_html = undef,
  $access_key_id      = undef,
  $secret_access_key  = undef,
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)
  if $ensure == 'present' {
    # Create Bucket
    exec { "create S3 bucket ${bucket_name} in ${region}":
      command => "aws s3api create-bucket --bucket ${bucket_name} \
                  --create-bucket-configuration LocationConstraint=${region}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      onlyif  => "/bin/true && ! aws s3api list-buckets \
                  --query 'Buckets[].Name' | grep ${bucket_name}\\\"",
    }

    # Config S3 website server hosting
    if $website_index_html {
      exec { "config website ${bucket_name} in ${region}":
        command => "aws s3 website s3://${bucket_name}/ --index-document ${website_index_html} --error-document ${website_error_html} --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        require => Exec["create S3 bucket ${bucket_name} in ${region}"],
      }
      ->
      file { '/tmp/public_access_policy.json':
        ensure  => file,
        mode    => '0600',
        content => template('aws_deploy/s3_public_access_policy.json.erb'),
      }
      ->
      exec { "config ${bucket_name} bucket policy in ${region}":
        command => "aws s3api put-bucket-policy --bucket ${bucket_name} --policy file:///tmp/public_access_policy.json --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      }
    }
  } else {
    # Delete Bucket
    exec { "delete bucket ${bucket_name} content":
      command => "aws s3 rm s3://${bucket_name} --recursive --region ${region}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    }
    ->
    exec { "delete bucket ${bucket_name}":
      command => "aws s3 rb s3://${bucket_name} --region ${region}",
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    }
  }
}