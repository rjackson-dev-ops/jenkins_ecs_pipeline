require 'aws-sdk-s3'
require 'base64'
require 'docker'
require 'cfndsl'

@image_id_path = 'blog-image-id'
@ecr_repo_url_path = 'blog-ecr-repo'
@repo = 'stelligent-demo-ecr'

desc 'Deploy ELB'
task 'deploy:elb' => :environment do
  puts 'deploying elb'

end