FROM python:3.6.0-alpine

WORKDIR /app
COPY . /app

RUN apk update \ 
    && apk --no-cache add gcc musl-dev \
    && pip --no-cache-dir install -r /app/requirements.txt \
    && apk --no-cache del gcc musl-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]

