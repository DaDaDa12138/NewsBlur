.PHONY: all
all: test

test: up_and_wait
        cd node && docker-compose run e2e-electron || true
        npx serve node/cypress/videos
up_and_wait: rm_persisted_data
        docker run --rm -v $$PWD:$$PWD -w $$PWD debian \
        sed -i \
        "s/http:\/\/docker.newsblur.com/http:\/\/some.host.com:port/" \
        docker/local_settings.py
        docker run --rm -v $$PWD:$$PWD -w $$PWD debian \
        sed -i \
        "s/'.newsblur.com'/'some.host.com'/" \
        docker/local_settings.py
        docker-compose up --build -d
        curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > wait.sh; bash wait.sh -t 0 some.host.com:port -- echo 'newsblur is up'; rm wait.sh
rm_persisted_data:
        docker-compose down --rmi=local -v && \
        rm -rf docker && git checkout docker
