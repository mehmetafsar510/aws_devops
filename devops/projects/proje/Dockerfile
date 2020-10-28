FROM python:alpine
WORKDIR /app
COPY  . ./
RUN pip install -r requirements.txt
EXPOSE 80
ENTRYPOINT ["python"]
CMD ["bookstore-api.py"]