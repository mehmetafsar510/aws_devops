eval "$(ssh-agent)" # komutu verin

ssh-add key.pem  # key.pem dosyasının bulunduğu klasördeyseniz bu komut yeterli.
                 # eğer aynı klasörde değilseniz ssh-add .ssh/key.pem yaz

ssh -A ec2-user@ec2-3-88-199-43.compute-1.amazonaws.com # public ec2 instance'nize normal bağlanın.

ssh ec2-user@[Your private EC2 private IP] # private ec2 instance'nize bağlanın.

