FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y --no-install-recommends  \
    ffmpeg=7:4.1.4-1~deb10u1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && gem install bundler -v 2.0.1

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp
RUN bundle exec rake assets:precompile RAILS_ENV=production && \
    bundle exec rake db:schema:load RAILS_ENV=production && \
    bundle exec rake db:schema:load RAILS_ENV=test && \
    bundle exec rails db:seed RAILS_ENV=production

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
ENV TZ='Asia/Tokyo'
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_LOG_LEVEL=INFO
EXPOSE 3000
