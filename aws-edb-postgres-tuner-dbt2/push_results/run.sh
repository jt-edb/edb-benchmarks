#!/bin/bash -eux
# Push DBT2 files to the S3 bucket
BUCKET_NAME="ebac-reports"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Extract the archive containing the report and data
tar xzf "${SCRIPT_DIR}/../execute/tuner-off/tuner-off.tar.gz" -C "${SCRIPT_DIR}"
tar xzf "${SCRIPT_DIR}/../execute/tuner-measurement/tuner-measurement.tar.gz" -C "${SCRIPT_DIR}"
tar xzf "${SCRIPT_DIR}/../execute/tuner-final/tuner-final.tar.gz" -C "${SCRIPT_DIR}"
mkdir dbt2-data
mv "${SCRIPT_DIR}/tmp/tuner-off" "${SCRIPT_DIR}/dbt2-data/"
mv "${SCRIPT_DIR}/tmp/tuner-measurement" "${SCRIPT_DIR}/dbt2-data/"
mv "${SCRIPT_DIR}/tmp/tuner-final" "${SCRIPT_DIR}/dbt2-data/"
rm -rf "${SCRIPT_DIR}/tmp"
# Copy infrastructure.yml and vars.yml
cp "${SCRIPT_DIR}/../infrastructure.yml" "${SCRIPT_DIR}/dbt2-data/"
cp "${SCRIPT_DIR}/../vars.yml" "${SCRIPT_DIR}/dbt2-data/"
cd "${SCRIPT_DIR}/dbt2-data"
date=$(date +'%Y-%m-%dT%H:%M:%S')

aws s3 cp infrastructure.yml "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/"
aws s3 cp vars.yml "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/"
for DIR in tuner-off tuner-measurement tuner-final; do
	aws s3 cp ${DIR}/readme.txt "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/${DIR}/"
	aws s3 cp ${DIR}/report.html "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/${DIR}/"
	aws s3 cp ${DIR}/db/ "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/${DIR}/db" --recursive
	aws s3 cp ${DIR}/driver/ "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/${DIR}/driver" --recursive
	aws s3 cp ${DIR}/txn/ "s3://${BUCKET_NAME}/${BENCHMARK_NAME}/${date}/${DIR}/txn" --recursive
done
