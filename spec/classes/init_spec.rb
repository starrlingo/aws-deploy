require 'spec_helper'
describe 'aws_s3' do

  context 'with default values for all parameters' do
    it { should contain_class('aws_s3') }
  end
end
