ANSIBLE_VAULT_ARGS ?= --ask-vault-pass

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

setup-all: ## Sets up all services
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --tags=setup-all

backup: ## Creates a new backup
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --tags=backup

start: ## Restarts services
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --tags=start

update: ## Performs an upgrade after making a backup
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --tags=backup,setup-redis,setup-gitlab,setup-postgres,setup-nginx-proxy,start

setup-all-and-restart: ## Sets up all services and restarts after that
	ansible-playbook $(ANSIBLE_VAULT_ARGS) -i inventory/hosts setup.yml --tags=setup-all,start
