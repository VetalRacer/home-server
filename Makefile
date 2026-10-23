ANSIBLE_VAULT_ARGS ?= --ask-vault-pass
TARGET ?=

check-target:
	@test "$(TARGET)" = test || test "$(TARGET)" = prod || \
		(echo "Set TARGET=test or TARGET=prod. Example: make setup-all TARGET=prod"; exit 2)

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

setup-all: check-target ## Sets up all services for TARGET=test or TARGET=prod
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --limit $(TARGET) --tags=setup-all

backup: check-target ## Creates a new backup for TARGET=test or TARGET=prod
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --limit $(TARGET) --tags=backup

start: check-target ## Restarts services for TARGET=test or TARGET=prod
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --limit $(TARGET) --tags=start

update: check-target ## Performs an upgrade for TARGET=test or TARGET=prod
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --limit $(TARGET) --tags=backup,setup-redis,setup-gitlab,setup-postgres,setup-nginx-proxy,start

setup-all-and-restart: check-target ## Sets up and restarts TARGET=test or TARGET=prod
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --limit $(TARGET) --tags=setup-all,start

setup-test: ## Sets up all services on the test server
	$(MAKE) setup-all TARGET=test

setup-prod: ## Sets up all services on the production server
	$(MAKE) setup-all TARGET=prod

restart-test: ## Restarts services on the test server
	$(MAKE) start TARGET=test

restart-prod: ## Restarts services on the production server
	$(MAKE) start TARGET=prod

deploy-test: ## Sets up and restarts all services on the test server
	$(MAKE) setup-all-and-restart TARGET=test

deploy-prod: ## Sets up and restarts all services on the production server
	$(MAKE) setup-all-and-restart TARGET=prod
