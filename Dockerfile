FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y --no-install-recommends  \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && gem install bundler -v 2.0.1

WORKDIR /myapp
COPY . /myapp
RUN bundle install

RUN bundle exec rake assets:precompile
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
ENV TZ='Asia/Tokyo'
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_LOG_LEVEL=INFO
EXPOSE 3000
