FROM python:alpine
COPY requirements.txt .
RUN /usr/local/bin/python -m pip install --upgrade pip && pip install -r requirements.txt
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python ./clarusshop-account.py 