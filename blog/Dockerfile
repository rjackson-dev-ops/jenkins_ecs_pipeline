FROM starefossen/ruby-node:latest

RUN umask 22 && mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install


COPY . .
CMD ["./start_blog.sh"]