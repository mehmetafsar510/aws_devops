FROM python:alpine
COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
EXPOSE 80
CMD python ./app.py
