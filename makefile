# Inspired from https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
# https://github.com/e-COSI/docker-bastillion/blob/master

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

ifndef RESTART
RESTART=no
endif

ifeq ($(RESTART),no)
else ifeq ($(RESTART),on-failure)
else ifeq ($(RESTART),always)
else
RESTART=no
endif

ifndef TAG_VERSION
TAG_VERSION=$(shell curl --silent "https://api.github.com/repos/bastillion-io/Bastillion/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/')
endif

ifndef URL
URL=$(shell curl --silent "https://api.github.com/repos/bastillion-io/Bastillion/releases/latest" | \
		grep -E 'https://[^ ]+bastillion-jetty-v[0-9._]+\.tar\.gz' | \
		sed -E 's/.*"(.*\.tar\.gz)"$$/\1/g')
endif

RUN=--env-file=./config.env --restart=$(RESTART) -p=$(PORT):$(EXPOSE) --name="$(APP_NAME)" $(IMAGE_NAME):$(TAG_VERSION)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build \
		--build-arg URL=$(URL) \
		--rm -t $(IMAGE_NAME):$(TAG_VERSION) .

build-nc: ## Build the container without caching
	docker build \
		--build-arg URL=$(URL) \
		--no-cache --rm -t $(IMAGE_NAME):$(TAG_VERSION) .

run-interactive: stop rm ## Run container on port configured in `config.env`
	docker run -i -t $(RUN)

run-detach: stop rm
	docker run -d $(RUN)

run: run-detach

rm:
	@docker rm "$(APP_NAME)" 2> /dev/null || true

rmi:
	@docker rmi "$(IMAGE_NAME)"

up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME) 2> /dev/null || true

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

prune-all: ## Clean all unused docker items
	docker system prune --all --force --volumes

# HELPERS

# generate script to login to aws docker repo
CMD_REPOLOGIN := "eval $$\( aws ecr"
ifdef AWS_CLI_PROFILE
CMD_REPOLOGIN += " --profile $(AWS_CLI_PROFILE)"
endif
ifdef AWS_CLI_REGION
CMD_REPOLOGIN += " --region $(AWS_CLI_REGION)"
endif
CMD_REPOLOGIN += " get-login --no-include-email \)"

# login to AWS-ECR
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	@eval $(CMD_REPOLOGIN)

version: ## Output the current version
	@echo "Latest version:"
	@echo -e "\t$(TAG_VERSION)"

url:
	@echo "Download latest version URL:"
	@echo -e "\t$(URL)"

info: version url ## Output information about latest bastillion
