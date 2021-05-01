## Projeyi ayaağa kaldırma

1. root'da .env.dev dosyası oluşturup içine aşağıdakileri ekleyiniz.
DB_HOST=db
DB_NAME=app
DB_USER=postgres
DB_PASS=supersecretpassword
POSTGRES_DB=app
POSTGRES_USER=postgres
POSTGRES_PASSWORD=supersecretpassword

2. Ardından docker-compose up

3. django komutu çalıştırabilmek için

docker-compose exec app python manage.py createsuperuser

