.PHONY: all build run

build:
	docker build -f deploy/docker/Dockerfile -t shinsa .

run:
	docker run -dit -v `pwd`/backend:/usr/local/shinsa -v `pwd`/frontend:/var/www/html -p8321:80 -p3321:3321 --name shinsa-local shinsa
