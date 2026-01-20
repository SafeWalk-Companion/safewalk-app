import * as cdk from 'aws-cdk-lib/core';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export interface PipelineStackProps extends cdk.StackProps {
  /**
   * The GitHub organization/user name
   */
  readonly githubOrg: string;

  /**
   * The GitHub repository name
   */
  readonly githubRepo: string;
}

export class AppPipelineStack extends cdk.Stack {
  /**
   * The IAM role that GitHub Actions will assume
   */
  public readonly deploymentRole: iam.Role;

  constructor(scope: Construct, id: string, props: PipelineStackProps) {
    super(scope, id, props);

    const { githubOrg, githubRepo } = props;

    // Import the existing GitHub OIDC provider instead of creating a new one
    const githubOidcProvider = iam.OpenIdConnectProvider.fromOpenIdConnectProviderArn(
      this,
      'github-oidc-provider-app',
      `arn:aws:iam::${cdk.Aws.ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com`
    );

    this.deploymentRole = new iam.Role(this, 'github-actions-deployment-role-sw-app', {
      roleName: 'github-actions-deployment-role-sw-app',
      assumedBy: new iam.WebIdentityPrincipal(
        githubOidcProvider.openIdConnectProviderArn,
        {
          StringEquals: {
            'token.actions.githubusercontent.com:aud': 'sts.amazonaws.com',
          },
          StringLike: {
            'token.actions.githubusercontent.com:sub': `repo:${githubOrg}/${githubRepo}:ref:refs/heads/main`,
          },
        }
      ),
      description: 'Role assumed by GitHub Actions for CDK deployments',
      maxSessionDuration: cdk.Duration.hours(1),
    });

    // CloudFormation permissions
    this.deploymentRole.addToPolicy(
      new iam.PolicyStatement({
        sid: 'CloudFormationPermissions',
        effect: iam.Effect.ALLOW,
        actions: [
          'cloudformation:CreateStack',
          'cloudformation:UpdateStack',
          'cloudformation:DeleteStack',
          'cloudformation:DescribeStacks',
          'cloudformation:DescribeStackEvents',
          'cloudformation:DescribeStackResources',
          'cloudformation:GetTemplate',
          'cloudformation:GetTemplateSummary',
          'cloudformation:ListStackResources',
          'cloudformation:CreateChangeSet',
          'cloudformation:DeleteChangeSet',
          'cloudformation:DescribeChangeSet',
          'cloudformation:ExecuteChangeSet',
          'cloudformation:ListChangeSets',
        ],
        resources: ['*'],
      })
    );

    // S3 permissions for CDK assets
    this.deploymentRole.addToPolicy(
      new iam.PolicyStatement({
        sid: 'S3AssetsPermissions',
        effect: iam.Effect.ALLOW,
        actions: [
          's3:GetObject',
          's3:PutObject',
          's3:DeleteObject',
          's3:ListBucket',
          's3:GetBucketLocation',
        ],
        resources: [
          `arn:aws:s3:::cdk-*-assets-${cdk.Aws.ACCOUNT_ID}-${cdk.Aws.REGION}`,
          `arn:aws:s3:::cdk-*-assets-${cdk.Aws.ACCOUNT_ID}-${cdk.Aws.REGION}/*`,
        ],
      })
    );

    // SSM permissions for CDK bootstrap version
    this.deploymentRole.addToPolicy(
      new iam.PolicyStatement({
        sid: 'SSMPermissions',
        effect: iam.Effect.ALLOW,
        actions: ['ssm:GetParameter'],
        resources: [
          `*`,
        ],
      })
    );

    // IAM permissions for CDK to manage roles
    this.deploymentRole.addToPolicy(
      new iam.PolicyStatement({
        sid: 'IAMPermissions',
        effect: iam.Effect.ALLOW,
        actions: ['iam:PassRole'],
        resources: [
          `arn:aws:iam::${cdk.Aws.ACCOUNT_ID}:role/cdk-*`,
        ],
      })
    );

    // STS permissions for CDK to assume roles
    this.deploymentRole.addToPolicy(
      new iam.PolicyStatement({
        sid: 'STSAssumeRolePermissions',
        effect: iam.Effect.ALLOW,
        actions: ['sts:AssumeRole'],
        resources: [
          `arn:aws:iam::${cdk.Aws.ACCOUNT_ID}:role/cdk-*`,
        ],
      })
    );

    new cdk.CfnOutput(this, 'DeploymentRoleArn', {
      value: this.deploymentRole.roleArn,
      description: 'ARN of the GitHub Actions Deployment Role',
    });
  }
}
