require 'yaml'

@region = 'us-west-1'
@kms_alias = 'alias/configKeyAlias'
@bucket = 'jenkins-demo-bucket'
@config_file = 'jenkins_ecs_config.yaml'
@vpc = 'tmp/vpc'
@subnets = '/tmp/subnets'


desc 'Get Configuration Values'
task 'get:configuration:values' do
  puts 'Getting configuration values'

  kms = Aws::KMS::Client.new region: @region

  s3 =   Aws::S3::Encryption::Client.new(
    kms_key_id: @kms_alias,
    kms_client: kms,
    region: @region
  )

  crossing = Crossing.new(s3)

  content = crossing.get_content(@bucket, @config_file)
  yml = YAML.safe_load(content)

  yml.each do |key, value|
    puts "key: #{key} - value: #{value}"
    File.write(@vpc, value) if key == 'vpc'
    File.write(@subnets, value) if key == 'subnets'
  end

end
