#!/bin/bash

if [ -z "$1" ]
  then
    echo "pass proxy as first command line argument"
    echo "  e.g. ./digest_checker.sh http://proxy.gtn:3128"
    exit 1
  else
    PROXY=$1
fi

if [ -z "$2" ]
  then
    echo "pause is not appointed as second command line argument"
    PAUSE=1h
    echo "use the default value '$PAUSE'"
    echo "to change it invoke the script in such way'./digest_checker.sh http://proxy.gtn:3128 30m'"
  else
    PAUSE=$2
fi

FILE_URLS_TO_CHECK[0]="http://xml.shavlik.com/data/partner/manifestAlt/partner.manifest.xml"
FILE_URLS_TO_CHECK[1]="http://xml.shavlik.com/data/hf7b.xml"
FILE_URLS_TO_CHECK[2]="http://xml.shavlik.com/data/oemcatalog.zip"
FILE_URLS_TO_CHECK[3]="http://xml.shavlik.com/data/oem/73/pd5.xml"
DOWNLOAD_DIR="./downloaded_files"

mkdir -p $DOWNLOAD_DIR

#export http_proxy=$PROXY

while true
do
  echo "============================================"
  echo "============================================"
  echo "$(date --utc --rfc-3339=seconds)[INFO]: try to reproduce CSPM-161"
  rm -rf ${DOWNLOAD_DIR}/*.fromproxycache ${DOWNLOAD_DIR}/*.withoutproxycache
  
  for url in ${FILE_URLS_TO_CHECK[*]}
  do
    echo "--------------------------------------------"
    filename=${url##*/}
    filename_from_proxycache=${DOWNLOAD_DIR}/${filename}.fromproxycache
    filename_without_proxycache=${DOWNLOAD_DIR}/${filename}.withoutproxycache
  
    echo "downloading from ${url}"
    echo "to ${filename_from_proxycache}"
    echo "from proxy cache"
    #wget --proxy=on --output-document=${filename_from_proxycache} ${url}
    curl --proxy ${PROXY} ${url} >${filename_from_proxycache}
    
    echo "downloading from ${url}"
    echo "to ${filename_without_proxycache}"
    echo "without proxy cache"
    #wget  --proxy=on --output-document=${filename_without_proxycache} \
    #  --header="Cache-Control: no-cache" ${url}
    curl --proxy ${PROXY} --header "Cache-Control: no-cache" ${url} >${filename_without_proxycache}
    
    diff ${filename_from_proxycache} ${filename_without_proxycache} > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
      echo "$(date --utc --rfc-3339=seconds)[INFO]: ${filename_from_proxycache} IS EQUAL to ${filename_without_proxycache}"
    else
      current_timestamp=$(date +%s)
      echo "$(date --utc --rfc-3339=seconds)[WARN]: [${current_timestamp}] ${filename_from_proxycache} IS NOT EQUAL to ${filename_without_proxycache}"
      mv ${filename_from_proxycache} ${filename_from_proxycache}.${current_timestamp}
      mv ${filename_without_proxycache} ${filename_without_proxycache}.${current_timestamp}
    fi
  done
  sleep $PAUSE
done
