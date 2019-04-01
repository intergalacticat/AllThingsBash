#!/bin/bash

usageinfo=$'\nUsage: ./bucketGone.sh -e <ENV> -b <BUCKETS> \n Required : -e <Name of environment : fiixgoat> \n Optional : -b <List of buckets : tenfiles,artifacts {Default : tenantfiles,databaseexportbucket,artifactsbucket,templatesbucket}>\n'

if [ $# -eq 0 ]
then
  echo "$usageinfo"
  exit 1
fi

DEFAULTBUCKETS="tenantfiles,databaseexportbucket,artifactsbucket,templatesbucket"

while [ -n "$1" ]; do
  case "$1" in
    -e)
      case "$2" in
        "") echo "ERROR : -e must be followed by environment name" ; echo "$usageinfo" ; exit 1 ;;
        *) ENVS=$2 ; shift ;;
      esac ;;
    -b)
      case "$2" in
        "") echo "No buckets entered, using default list : $DEFAULTBUCKETS" ; shift ;;
         *) BUCKETS=$2 ; shift ;;
      esac ;;
    --) shift ; break ;;
     *) echo "$usageinfo" ; exit 1 ;;
  esac
  shift
done

if [ -z $ENVS ]
then
  echo "ERROR : -e must be followed by environment name"
  echo "$usageinfo"
  exit 1
else
  echo "Env selected : $ENVS"
fi

if [ -z $BUCKETS ]
then
  echo "No buckets entered, using default list : $DEFAULTBUCKETS"
  BUCKETLIST=$(echo "$DEFAULTBUCKETS" | tr "," "\n")
else
  BUCKETLIST=$(echo "$BUCKETS" | tr "," "\n")
  echo "Buckets : "${BUCKETLIST[@]}
fi

for bucketName in $BUCKETLIST;
do
  aws s3 ls | grep $ENVS | grep $bucketName | cut -d" " -f3 > $ENVS-bucketList.txt

  FileList=`cat $ENVS-bucketList.txt`


  for bucket in $FileList;
  do
    echo "Removing bucket --> $bucket"
    aws s3 rb s3://$bucket --force
  done

done
