FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y ffmpeg && \
    gem install bundler -v 2.0.1 && mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp
RUN bundle exec rake assets:precompile RAILS_ENV=production && \
    bundle exec rake db:schema:load RAILS_ENV=production && \
    bundle exec rake db:schema:load RAILS_ENV=test && \
    bundle exec rails db:seed RAILS_ENV=production

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_LOG_LEVEL=INFO
EXPOSE 3000

# Start the main process.
# CMD ["rails", "server", "-b", "0.0.0.0","-e","production"]
