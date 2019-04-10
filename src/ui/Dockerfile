FROM alpine:3.9

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

RUN mkdir $APP_HOME

WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
COPY . $APP_HOME
RUN apk add --no-cache build-base ruby ruby-bundler ruby-dev ruby-json \
    && bundle install \
    && rm -rf /root/.bundle \
    && apk --no-cache del build-base ruby-dev

CMD ["puma"]
