#!/bin/bash -eux
# Push DBT2 files to the S3 bucket
BUCKET_NAME="ebac-reports"

# Extract the archive containing the report and data
tar xzf ../execute/dbt2_data/dbt2-data.tar.gz -C .
mv ./tmp/dbt2-data .
rm -rf ./tmp
# Copy infrastructure.yml and vars.yml
cp ../infrastructure.yml dbt2-data/.
cp ../vars.yml dbt2-data/.
cd dbt2-data
date=$(date +'%Y-%m-%dT%H:%M:%S')

aws s3 cp infrastructure.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/
aws s3 cp vars.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/
aws s3 cp report.html s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/
aws s3 cp db/ s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/db --recursive
aws s3 cp txn/ s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/txn --recursive
