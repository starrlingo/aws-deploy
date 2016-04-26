# Definition: aws_deploy::lambda::func
#
# This definition manage AWS lambda function
#
# Parameters:
# - ensure: 'present', 'absent' are allowed
# - region: Deployed region, default value is us-west-2
# - runtime: Currently support 'nodejs', 'nodejs4.3', 'java8', 'python2.7'
# - handler: The function within your code that Lambda calls to begin execution.
# - timeout: The function execution timeout value in second
# - memory: The amount of memory, in MB
# - function_name: The name you want to assign to the function you are uploading
# - exec_role_arn: The execution IAM role ARN of Lambda to access any resources
# - zip_file_path: The path to the zip file of the code you are uploading
# Requires: None
#
# Sample Usage:
# aws_deploy::lambda::function { "test function":
#   ensure => 'present',
#   region => 'us-west-2',
#   timeout => '180',
#   memory => '128',
#   function_name => "test",
#   exec_role_arn => "arn:aws:iam::${myaccountId}:role/my_lambda_exec_role",
#   zip_file_path => "/tmp/test.zip",
# }
#
define aws_deploy::lambda::function (
  $ensure,
  $region,
  $function_name,
  $runtime = 'nodejs',
  $handler = 'index.handler',
  $timeout = '300',
  $memory = '128',
  $exec_role_arn = undef,
  $zip_file_path = undef,
){
  $valid_ensures = [ 'absent', 'present' ]
  validate_re($ensure, $valid_ensures)

  case $ensure {
    'present': {
      exec { "create lambda ${function_name} in ${region}":
        command => "aws lambda create-function \
                    --function-name ${function_name} --runtime ${runtime} \
                    --role ${exec_role_arn} --handler ${handler} \
                    --timeout ${timeout} --memory-size ${memory} \
                    --region ${region} --zip-file fileb://${zip_file_path}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && ! aws lambda get-function-configuration \
                    --function-name ${function_name} --region ${region}",
      }
      ->
      exec { "update lambda ${function_name} config in ${region}":
        command => "aws lambda update-function-configuration \
                    --function-name ${function_name} --role ${exec_role_arn} \
                    --handler ${handler} --timeout ${timeout} \
                    --memory-size ${memory} --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && aws lambda get-function-configuration \
                    --function-name ${function_name} --region ${region}",
      }
      ->
      exec { "update lambda ${function_name} code in ${region}":
        command => "aws lambda update-function-code \
                    --function-name ${function_name} \
                    --region ${region} --zip-file fileb://${zip_file_path}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && aws lambda get-function-configuration \
                    --function-name ${function_name} --region ${region}",
      }
    }
    'absent': {
      # delete function
      exec { "create lambda ${function_name} in ${region}":
        command => "aws lambda delete-function \
                    --function-name ${function_name} --region ${region}",
        path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        onlyif  => "/bin/true && aws lambda get-function-configuration \
                    --function-name ${function_name} --region ${region}",
      }
    }
    default: {
      fail("${ensure} is not supported")
    }
  }
}