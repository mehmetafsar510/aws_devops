#! /bin/bash
apt-get update -y
apt-get install git -y
apt-get install python3 -y
cd /home/ubuntu/
git clone https://github.com/mehmetafsar510/depo
cd /home/ubuntu/depo
apt install python3-pip -y
apt-get install python3.7-dev libmysqlclient-dev -y
pip3 install -r requirements.txt
cd /home/ubuntu/depo/src
sed -i "s/'your DB password without any quotes'/${dbpassword}/g" .env
cd /home/ubuntu/depo/src/cblog
sed -i "s/'database name in RDS is written here'/'${dbname}'/g" settings.py
sed -i "s/'database master username in RDS is written here'/'${dbuser}'/g" settings.py
sed -i "s/'database endpoint is written here'/'${db_address}'/g" settings.py
sed -i "s/'database port is written here'/'3306'/g" settings.py
sed -i "s/'please enter your s3 bucket name'/'${bucket_name}'/g" settings.py
sed -i "s/'please enter your s3 region'/'us-east-1'/g" settings.py
cd /home/ubuntu/depo/src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:80