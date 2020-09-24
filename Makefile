ifndef ENV
$(error "Must set ENV")
endif

ifndef FORCE
	FORCE := "false"
endif

RELEASE_VERSION := $(shell git show HEAD:VERSION)
LOOSE_VERSION := $(shell git describe)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
tag := $(shell git describe --abbrev=0)
OC_NAMESPACE := $(shell oc project -q)
TEST_VERSION := $(shell cat ./VERSION)
NEW_VERSION := $(shell ./scripts/increment_version.sh  -p $(TEST_VERSION) 'beta')



preflight:
	@set -e ; \
	if [[ $(ENV) != $(OC_NAMESPACE) ]]; then \
		echo 'CODE RED: You are logged on to $(OC_NAMESPACE), and are not logged into the $(ENV) namespace'; \
		exit 1; \
	fi;

deploy: preflight
	@if [[ $(FORCE) != "true" ]]; then \
		read -p "WARNING. You are about to release version $(LOOSE_VERSION) to $(ENV). Press enter to confirm."; \
	fi;
	docker run -it -v $(HOME)/.kube:/root/.kube -v $(PWD):/app -w /app bobbydvo/ansible ansible-playbook -vvv App.yaml -i $(ENV).ini -e iac_version=$(LOOSE_VERSION)

jenkins-deploy: preflight
	@if [[ $(FORCE) != "true" ]]; then \
		read -p "WARNING. You are about to release version $(LOOSE_VERSION) to $(ENV). Press enter to confirm."; \
	fi;
	ansible-playbook -vvv App.yaml -i $(ENV).ini -e iac_version=$(LOOSE_VERSION)
