#!/bin/bash -eux
# Push HammerDB files to the S3 bucket
BUCKET_NAME="ebac-reports"

# Extract the archive containing the report and data
mkdir -p tprocc-data
cp -pr ../execute/hammerdb.log tprocc-data/.
# Copy infrastructure.yml and vars.yml
cp ../infrastructure.yml tprocc-data/.
cp ../vars.yml tprocc-data/.
cd tprocc-data
date=$(date +'%Y-%m-%dT%H:%M:%S')

aws s3 cp ./ "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/" --recursive
