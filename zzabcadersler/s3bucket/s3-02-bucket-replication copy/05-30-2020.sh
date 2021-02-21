# 05-30-2020
# AWS Lab Session - Callahan
# Simple Storage Service (S3) 
# Bucket Replication
# create source bucket in  n.virginia region as static website hosting
# create a new bucket for static website - pet.clarusway.call
    # Versioning    Enabled
    # Server access logging Disabled
    # Tagging   0 Tags
    # Object-level logging  Disabled
    # Default encryption    None
    # CloudWatch request metrics    Disabled
    # Object lock   Disabled
    # Allow all public access
# show static website hosting settings from properties of new bucket
    # enter index.html as default file
# set the static website bucket policy as shown below
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bucket-name/*"
        }
    ]
}
# upload index.html first version and image to the bucket
<html>
    <head>
        <title> Cute Cat </title>
    </head>
    <body>
        <center><h1> My Cute Cat </h1><center>
        <center><img src="cat.jpg" alt="Cute Cat"</center>
        <!-- <p><center> <a href="/kitten/cutest.html"> Click here to see cutest cat ever!!!</a> </p> -->
    </body>
</html>
# open static website url in browser and show its working


New Exercise:
# create destination bucket in ohio region 
# create a new bucket - pet.clarusway.call.back
    # Versioning    Enabled
    # Server access logging Disabled
    # Tagging   0 Tags
    # Object-level logging  Disabled
    # Default encryption    None
    # CloudWatch request metrics    Disabled
    # Object lock   Disabled
    # Allow all public access
# create iam policy for crr replication s3-crr-policy-for-pet-clarusway-call with following permissons 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::pet.clarusway.call",
                "arn:aws:s3:::pet.clarusway.call/*"
            ]
        },
        {
            "Action": [
                "s3:ReplicateObject",
                "s3:ReplicateDelete",
                "s3:ReplicateTags",
                "s3:GetObjectVersionTagging"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::pet.clarusway.call.backup/*"
        }
    ]
}
# create s3 role for crr replication - s3-crr-role-pet-clarusway-call using the policy above
# enable cross-region replication on the entire source bucket
    # open replication from management tab
    # add replication rule  
        # set source: entire bucket
        # destination bucket: buckets in this account - destination bucket
        # rule options screen, IAM role: s3-crr-role-pet-clarusway-call
# show that destination bucket has nothing after enabling crr
# upload the new version of index.html in the source bucket
# check destination bucket and show that new uploaded file is replicated



New Exercise
# enable cross-region replication on the folder of the source bucket
    # open replication from management tab
    # add replication rule  
        # set source: prefix - name of the folder - kitten
        # destination bucket: buckets in this account - destination bucket
        # rule options screen, IAM role: s3-crr-role-pet-clarusway-call
# upload the cutest.html and cat.jpg under kitten folder in the source bucket
<html>
    <head>
        <title> Cutest Cat </title>
    </head>
    <body>
        <center><h1> My Cutest Cat </h1><center>
        <center><img src="cat.jpg" alt="Cutest Cat"</center>
    </body>
</html>
# check destination bucket and show that new uploaded files is replicated
# enable cross-region replication by tagging on the source bucket
    # open replication from management tab
    # add replication rule  
        # set source: tag - key:importance - value:high
        # destination bucket: buckets in this account - destination bucket
        # rule options screen, IAM role: s3-crr-role-pet-clarusway-call
# upload the index.html version 3 and tag it importance:high in the source bucket
<html>
    <head>
        <title> Cute Cat </title>
    </head>
    <body>
        <center><h1> My Cute Cat of Version 3 </h1><center>
        <center><img src="cat.jpg" alt="Cute Cat"</center>
        <p><center> <a href="/kitten/cutest.html"> Click here to see cutest cat ever!!!</a> </p>
    </body>
</html>
# check destination bucket and show that new uploaded file is replicated
# copy a file in the source bucket into the kitten folder, show that is also replicated
# delete a replicated file on source bucket and show that deleting an object from a source bucket does not delete it from the destination bucket.