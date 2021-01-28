#!/bin/bash

aws s3 ls

aws s3 cp RomanNumber.zip s3://staticwebcors2514

aws s3 cp  cors_bucket s3://staticwebcors2514 --recursive

aws s3 cp apigw s3://staticweb2514 --recursive

aws s3 cp s3cors s3://staticweb2514 --recursive





