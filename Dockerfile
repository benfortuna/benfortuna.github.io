FROM ruby:2.1

WORKDIR /srv/jekyll

EXPOSE 4000 80

ENV BUNDLE_PATH /bundle

COPY Gemfile _config.yml index.md about.md favicon.png ./
COPY _posts _posts
COPY docs docs
#COPY _layouts ./_layouts/
COPY _includes _includes
#COPY _sass ./_sass/
#COPY css css
#COPY img ./img/
#COPY about ./about/

COPY scripts scripts

CMD ["scripts/jekyll-serve.sh"]
