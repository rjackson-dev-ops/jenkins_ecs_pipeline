FROM ruby:2.3.7

RUN umask 22 && mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
        libpq-dev \
        python-dev \
        python-pip \
    && gem install crossing --no-rdoc --no-ri \
    && pip install awscli \
    &&  apt-get install -y nodejs \
    && npm --prefix  install \
    && npm --prefix run bundle

RUN bundle install


COPY . .
CMD ["./start_timeapp.sh"]