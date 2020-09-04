1 Hub 'ın bütün portları tek 1 Collision domain oluşturur
1 Switch 'ın tek bir portu tek 1 Collision domain oluşturur
1 Switch 'ın bütün portları tek 1 Broadcast oluşturur
1 Router 'ın tek bir portu 1 tane Broadcast domain oluşturur

SSH bağlantısının kesilmesini önlemek için  internetten baktım bende çalıştı. sırasıyla şu komutları ec2 da çalıştırıyoruz
    echo 'ClientAliveInterval 60' | sudo tee --append /etc/ssh/sshd_config
    sudo service sshd restart
   logout
komutları EC2 da çalıştırıyoruz logout dedikten sonra tekrar bağlanınca ec2 ya kesilmiyor
