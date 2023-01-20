#!/bin/bash -eux
# Push pgbench files to the S3 bucket
BUCKET_NAME="ebac-reports"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Copy infrastructure.yml and vars.yml
cp -r ${SCRIPT_DIR}/../execute/pgbench_data ${SCRIPT_DIR}/report-data
cp ${SCRIPT_DIR}/../infrastructure.yml ${SCRIPT_DIR}/report-data/.
cp ${SCRIPT_DIR}/../vars.yml ${SCRIPT_DIR}/report-data/.

date=$(date +'%Y-%m-%dT%H:%M:%S')

aws s3 cp ${SCRIPT_DIR}/../infrastructure.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/infrastructure.yml
aws s3 cp ${SCRIPT_DIR}/../vars.yml s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/vars.yml
aws s3 cp ${SCRIPT_DIR}/report-data/ s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/report-data --recursive
