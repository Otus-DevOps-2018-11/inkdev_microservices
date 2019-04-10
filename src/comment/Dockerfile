FROM alpine:3.9

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN apk add --no-cache build-base ruby ruby-bundler ruby-dev ruby-json \
    && bundle install --clean --no-cache --force \
    && rm -rf /root/.bundle \
    && apk --no-cache del build-base ruby-dev
COPY . $APP_HOME

CMD ["puma"]
