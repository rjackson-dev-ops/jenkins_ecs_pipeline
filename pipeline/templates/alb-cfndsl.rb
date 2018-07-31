# rubocop:disable Metrics/BlockLength
CloudFormation do
  Description 'Contains configuration information to automatically build a ELB.'

  Parameter('vpc') do
    Type 'String'
    Description 'The VPC to deploy the instance to'
  end

  Parameter('ASGSubnets') do
    Type 'CommaDelimitedList'
    Description 'The subnet IDs the ELB should be attached to.'
  end

  Parameter('ELBSecurityGroup') do
    Type 'String'
    Description 'The ECS Cluster ELB Security Group used for Ingress.'
  end

  # ElasticLoadBalancingV2
  Resource('LoadBalancerListener') do
    Type 'AWS::ElasticLoadBalancingV2::Listener'
    Property('DefaultActions', [{
               TargetGroupArn: Ref('LoadBalancerTargetGroup'),
               Type: 'forward'
             }])
    Property('LoadBalancerArn', Ref('LoadBalancer'))
    Property('Port', 80)
    Property('Protocol', 'HTTP')
  end

  Resource('LoadBalancer') do
    Type 'AWS::ElasticLoadBalancingV2::LoadBalancer'
    Property('Scheme', 'internal')
    Property('SecurityGroups', [Ref('ELBSecurityGroup')])
    Property('Subnets', Ref('ASGSubnets'))
  end

  Resource('LoadBalancerTargetGroup') do
    Type 'AWS::ElasticLoadBalancingV2::TargetGroup'
    Property('HealthCheckIntervalSeconds', 30)
    Property('HealthCheckProtocol', 'HTTP')
    Property('HealthCheckPath', '/')
    Property('HealthCheckTimeoutSeconds', 7)
    Property('HealthyThresholdCount', 2)
    Property('Port', 8080)
    Property('Protocol', 'HTTP')
    Property('UnhealthyThresholdCount', 10)
    Property('VpcId', Ref('vpc'))
    Property('TargetGroupAttributes', [
               'Key' => 'deregistration_delay.timeout_seconds',
               'Value' => 20
             ])
  end

