FROM python:alpine
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 80
CMD ["python", "bookstore-api.py"]


#FROM ---> hub.docker.com/_/python ---> Fatklı environmentları göster. Alpine kullanıyoruz çünkü 5 MB dır ve gereksiz componentleri yoktur içerisinde. Mesela bash yoktur. Alpine boyutunu göstermek için hub.docker.com/_/alpine da genel tanımı verebilirsin.

#COPY ---> soldaki bulunduğumuz klasör sağdaki konteyner'ın için location belirtir. 

#RUN ---> -r: read the file named requirements.txt

# EXPOSE: container'ın hangi porttan yayın yapacağını belirtir. 

#docs.docker.com/reference ---> Dosyayı oluşturduktan sonra bu adresten build komutu ile birlikte diğer komutları da göster