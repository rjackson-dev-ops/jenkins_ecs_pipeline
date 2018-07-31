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

desc 'Authenticate ECR'
task 'ecr:authenticate' do
  ecr_client = Aws::ECR::Client.new(region: 'us-west-1')

  # Grab your authentication token from AWS ECR
  token = ecr_client.get_authorization_token(
    registry_ids: [ENV['AWS_ACCOUNT_ID']]
  ).authorization_data.first

  # Remove the https:// to authenticate
  ecr_repo_url = token.proxy_endpoint.gsub('https://', '')

  # Authorization token is given as username:password, split it out
  user_pass_token = Base64.decode64(token.authorization_token).split(':')

  # Call the authenticate method with the options
  Docker.authenticate!('username' => user_pass_token.first,
                       'password' => user_pass_token.last,
                       'email' => 'none',
                       'serveraddress' => ecr_repo_url)

  File.write(@ecr_repo_url_path, ecr_repo_url)

  puts "Authenticated: #{ecr_repo_url} with with Docker on this machine."
end

desc 'Tag blog image'
task 'blog:tag' do
  image = Docker::Image.get(File.read(@image_id_path))

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  ecr_repo = "#{File.read(@ecr_repo_url_path)}/#{@repo}"

  image.tag(repo: ecr_repo, tag: 'latest')

  puts "Image: #{image.id} has been tagged: #{image.info['RepoTags'].last}."
end

desc 'Push blog image'
task 'blog:push' do
  image = Docker::Image.get(File.read(@image_id_path))
  ecr_repo = "#{File.read(@ecr_repo_url_path)}/#{@repo}"
  repo_tag = "#{ecr_repo}:latest"

  # Authentication is required for this step
  if Docker.creds.nil?
    Rake::Task['ecr:authenticate'].reenable
    Rake::Task['ecr:authenticate'].invoke
  end

  image.push(nil, repo_tag: repo_tag)

  puts "Tag: #{repo_tag} pushed to ECR."
end
