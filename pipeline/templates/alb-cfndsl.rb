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
    Property('Certificates', [{
               CertificateArn: FnJoin(
                 '', ['arn:aws:iam::', Ref('AWS::AccountId'),
                      ':server-certificate/', Ref('certName')]
               )
             }])
    Property('DefaultActions', [{
               TargetGroupArn: Ref('LoadBalancerTargetGroup'),
               Type: 'forward'
             }])
    Property('LoadBalancerArn', Ref('LoadBalancer'))
    Property('Port', 443)
    Property('Protocol', 'HTTPS')
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
    Property('HealthCheckProtocol', 'HTTPS')
    Property('HealthCheckPath', '/health')
    Property('HealthCheckTimeoutSeconds', 7)
    Property('HealthyThresholdCount', 2)
    Property('Port', 8443)
    Property('Protocol', 'HTTPS')
    Property('UnhealthyThresholdCount', 10)
    Property('VpcId', Ref('vpc'))
    Property('TargetGroupAttributes', [
               'Key' => 'deregistration_delay.timeout_seconds',
               'Value' => 20
             ])
  end

  SNS_Topic(:alarmTopic) do
    DisplayName 'SVS-CSM-ALARM-LOAD-BALANCER'
    Subscription [{
      'Endpoint' => 'uscis-ver-vdm@excella.com',
      'Protocol' => 'email'
    }]
  end

  CloudWatch_Alarm(:loadbalancerHealthyHosts) do
    AlarmDescription 'No Healthy Hosts in LoadBalancer'
    MetricName 'HealthyHostCount'
    Namespace 'AWS/ApplicationELB'
    Statistic 'Average'
    Period '300'
    EvaluationPeriods '1'
    Threshold '0'
    AlarmActions [Ref(:alarmTopic)]
    Dimensions [
      Dimension(
        Name: 'LoadBalancer',
        Value: FnGetAtt('LoadBalancer', 'LoadBalancerFullName')
      ),
      Dimension(
        Name: 'TargetGroup',
        Value: FnGetAtt('LoadBalancerTargetGroup', 'TargetGroupFullName')
      )
    ]
    ComparisonOperator 'LessThanOrEqualToThreshold'
  end

  Output('LoadBalancerName', Ref('LoadBalancerTargetGroup'))
  Output('LoadBalancerUrl', FnGetAtt('LoadBalancer', 'DNSName'))
end
# rubocop:enable Metrics/BlockLength
