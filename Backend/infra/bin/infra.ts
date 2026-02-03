#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib/core';
import { AppBackendStack } from '../lib/app-backend-stack';

const app = new cdk.App();

new AppBackendStack(app, 'safewalk-app-backend-stack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});