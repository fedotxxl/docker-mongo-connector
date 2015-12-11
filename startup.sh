#!/bin/bash

echo "rs.isMaster()" > is_master_check
is_master_result=`mongo --host mongo< is_master_check`

expected_result="\"ismaster\" : true"

while true;
do
  if [ "${is_master_result/$expected_result}" = "$is_master_result" ] ; then
    echo "Waiting for Mongod node to assume primary status..."
    sleep 3
    is_master_result=`mongo --host mongo< is_master_check`
  else
    echo "Mongod node is now primary"
    break;
  fi
done

sleep 1

mongo="${MONGO:-mongo}"
elasticsearch="${ELASTICSEARCH:-elasticsearch}"

mongo-connector --auto-commit-interval=0 --oplog-ts=/job/mongo-connector/oplog.ts -m ${mongo}:27017 -t ${elasticsearch}:9200 -d elastic_doc_manager -c /job/mongo-connector/config.json --logfile=/job/mongo-connector/mongo-connector.log
