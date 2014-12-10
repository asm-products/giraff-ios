#!/bin/bash
# Giraff (c) 2014 by Assembly
#

source ../../bin/setEnv.sh

sed -e "s/DEV_PARSE_APPLICATION_ID/${DEV_PARSE_APPLICATION_ID}/g" -e "s/DEV_PARSE_MASTER_KEY/${DEV_PARSE_MASTER_KEY}/g" -e "s/PARSE_APPLICATION_ID/${PARSE_APPLICATION_ID}/g" -e "s/PARSE_MASTER_KEY/${PARSE_MASTER_KEY}/g" global.json.template >global.json
