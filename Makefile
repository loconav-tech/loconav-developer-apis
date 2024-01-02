VERSION := $(shell cat version.txt | tr -d '\n')
DEV_ENV:=.env
TEST_ENV:=.test.env
APP_NAME:=loconav_developer_apis_app
REPO_NAME:=loconav-developer-apis
DEFAULT_SHELL:=/bin/bash
IMAGE_NAME:=$(REPO_NAME)

DEV_DC:=docker-compose --env-file=$(DEV_ENV)
DEV_DA:=docker attach $(APP_NAME)
TEST_DC:=docker-compose --env-file=$(TEST_ENV)

BUILD_INFO:=run app rake meta_endpoints:add_build_info
CREATE_DB:=run app rails db:create
MIGRATE_DB:=run app rails db:migrate
RUN_SIDEKIQ:=run sidekiq up
DROP_DB:=run app rails db:drop

ECR_ADDRESS:=loconav.azurecr.io
ECR_IMAGE_TAG:=$(ECR_ADDRESS)/$(REPO_NAME):$(VERSION)
default: dev_server

setup:
	docker volume create --name=pg-development
	docker volume create --name=pg-test
	docker volume create --name=redis-development
	docker volume create --name=redis-test
	mkdir -p volumes/test
	mkdir -p volumes/development
	$(DEV_DC) $(CREATE_DB)
	$(TEST_DC) $(CREATE_DB)

dev_server:
	$(DEV_DC) build
	$(DEV_DC) $(BUILD_INFO)
	$(DEV_DC) $(MIGRATE_DB)
	$(DEV_DC) --profile server up -d
	$(DEV_DA)

dev_shell:
	$(DEV_DC) run app bash

test:
	$(TEST_DC) build
	$(TEST_DC) $(MIGRATE_DB)
	$(TEST_DC) run app rspec

documentation:
	 RAILS_ENV=test PATTERN=spec/rswag/**/*.rb rails rswag:specs:swaggerize

reset:
	$(DEV_DC) $(DROP_DB)
	$(TEST_DC) $(DROP_DB)

docker_image:
	docker build -t $(IMAGE_NAME):$(VERSION) -t $(ECR_IMAGE_TAG) --build-arg BUNDLE_RUBYGEMS__PKG__GITHUB__COM .

ecr_login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URL)

docker_push:
	docker push $(ECR_IMAGE_TAG)

push: ecr_login docker_image docker_push

worker:
	$(DEV_DC) build sidekiq
	$(DEV_DC) --profile worker up -d

prepare:
	rm -rf tools
	mkdir -p tools
	cd tools && git clone --depth 1 git@github.com:loconav-tech/app-configurator
