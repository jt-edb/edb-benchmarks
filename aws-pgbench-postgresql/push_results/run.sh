#!/bin/bash -eux
# Push pgbench files to the S3 bucket
BUCKET_NAME="ebac-reports"

# Copy infrastructure.yml and vars.yml
cp -r ../execute/pgbench_data report-data
cp ../infrastructure.yml ./report-data/.
cp ../vars.yml ./report-data/.

date=$(date +'%Y-%m-%dT%H:%M:%S')

aws s3 cp ../infrastructure.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/infrastructure.yml
aws s3 cp ../vars.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/vars.yml
aws s3 cp report-data/ s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/report-data --recursive
