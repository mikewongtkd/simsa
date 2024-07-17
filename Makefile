.PHONY: all build run

build:
	docker build -f deploy/docker/Dockerfile -t simsa .

run:
	docker run -dit -v `pwd`/backend:/usr/local/simsa -v `pwd`/frontend:/var/www/html -p8321:80 -p3321:3321 --name simsa-local simsa
