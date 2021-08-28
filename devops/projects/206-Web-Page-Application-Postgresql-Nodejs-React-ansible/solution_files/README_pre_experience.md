
## Ansible Project Notes

- 3 instances will be created. 

Security Groups:
```
Postgresql node: port 5432 and 22 from anywhere
nodejs and react node: port 3000, 5000, and 22 from anywhere
```

```bash
#! /bin/bash

yum update -y
yum install git -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
newgrp docker
systemctl restart docker
```

### POSTGRESQL CONTAINER
Bunun için ilk olarak dockerfile oluşturalım. Projede kullanılacak `clarusdb`
ve todo table `init.sql` adında bir dosyaya yazdırılacak bu init.sql file postgresql de
 `docker-entrypoint-initdb.d/` dosyasının altına atılmalı. Bunun için önce init.sql i oluşturalım.

- vi init.sql
```sql
CREATE DATABASE clarustodo;

\c clarustodo;

CREATE TABLE todo(
    todo_id SERIAL PRIMARY KEY,
    description VARCHAR(255)
);
```

- Dockerfile
```dockerfile
FROM postgres

RUN mkdir -p /tmp/psql_data/

COPY ./deneme/init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
```

- pgadmin den oluşan database ve table gösterilebilir

- Imaj oluşturma
```bash
docker build -t serkangumus06/postgre .
```

- Container oluşturma
```bash
docker run --name serdar_postgre -e POSTGRES_PASSWORD=Pp123456789 -p 5432:5432 -d serkangumus06/postgre:latest
```

- Postgress .env password vault işlemi

```
ansible-vault create secret.yml
```

New Vault password: xxxx
Confirm Nev Vault password: xxxx

```yml
pwhash: Pp12345678
```

- look at the content

```bash
$ cat secret.yml
```
```
33663233353162643530353634323061613431366332373334373066353263353864643630656338
6165373734333563393162333762386132333665353863610a303130346362343038646139613632
62633438623265656330326435646366363137373333613463313138333765366466663934646436
3833386437376337650a636339313535323264626365303031366534363039383935333133306264
61303433636266636331633734626336643466643735623135633361656131316463
```
- how to use it:

- open the docker_postgre.yml than under the become: true add vars_files: secret.yml and at the end of the page add  under env add {{ pwhash | password_hash ('sha512') }}

```bash
$ sudo vi docker_postgre.yml

```

```yml
- name: xxxxxxx
  hosts: all
  become: true
  vars_files:
    - secret.yml
  tasks:
    - name: mehmet_postgre
      env:
        POSTGRES_PASSWORD: "{{ pwhash | password_hash ('sha512') }}"
```

- run the plaaybook


```bash
$ ansible-playbook --ask-vault-pass docker_postgre.yml
```
Vault password: xxxx

## Frontend ve Backend de Node'ların hazırlanması

- Nodejs kurulumu

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
```
https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html

- Kurulduktan sonra edward hocamın repoyu react ve nodejs e indir. 
```bash
git clone https://github.com/edwardBenedict/todo-app-pern.git
```

Nodejs instance için
nodejs e gel ve server folder'ının altına

.env oluştur

SERVER_PORT=5000
DB_USER=postgres
DB_PASSWORD=Pp123456789
DB_NAME=clarustodo
DB_HOST=<postgre node's Internal IP>
DB_PORT=5432

- dependency’lerin server alt klasörünün içinde çalışması için

```bash
npm install
npm install -g --force nodemon
npm start
```
- 5000 portundan deneyelim
http://<nodejs Public DNS>:5000/todos --> bu yapıldığında 
[] köşeli parantez görülecektir

- React Node'un ayarlanması

- indirilen git repository de client klasörünün altına girelim

- .env file oluştur
REACT_APP_BASE_URL=http://<Nodejs instance Public Ip ya da DNS>:5000/

- dependency’lerin server alt klasörünün içinde çalışması için
```bash
npm install
npm install -g --force nodemon
npm start
```

- <React Public IP:3000> ---> yayın buradan yapılıyor

------------------------------------

Bu ilk aşaması idi

Docker için role

https://galaxy.ansible.com/geerlingguy/docker

For gather_facts explanation :https://abhijeet-kamble619.medium.com/10-things-you-should-start-using-in-your-ansible-playbook-808daff76b65

--------------------------

1. Most of the modules and plugins in community.docker require the Docker SDK for Python. The SDK needs to be installed on the machines where the modules and plugins are executed, and for the Python version(s) with which the modules and plugins are executed.

You can install the Docker SDK for Python for Python 2.7 or Python 3 as follows:

```bash
pip install docker
```


Resources

1. https://faun.pub/launch-and-configure-docker-container-using-ansible-playbook-95607550623f