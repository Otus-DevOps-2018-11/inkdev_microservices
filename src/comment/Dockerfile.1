FROM ruby:2.2
RUN rm /etc/apt/sources.list && echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted' > /etc/apt/sources.list && apt update --force-yes && apt-get install -y --force-yes build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
