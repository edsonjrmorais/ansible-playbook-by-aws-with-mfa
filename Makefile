.PHONY: lint
# NOTE: As Ansible does only work on *NIX systems,
# there's no use to make the Makefile Windows Compatible.
# For more information please read: 
# http://blog.rolpdog.com/2020/03/why-no-ansible-controller-for-windows.html

current_dir = $(shell pwd)
playbook ?= main.yaml

help:
	@echo "TODO"

check-devops_operator:
	@if [ -z "${devops_operator}" ]; then echo "devops_operator is required."; exit 1; fi

check-aws_team_account:
	@if [ -z "${aws_team_account}" ]; then echo "aws_team_account is required."; exit 1; fi

check-mfa_token:
	@if [ -z "${mfa_token}" ]; then echo "mfa_token is required."; exit 1; fi

checks: check-devops_operator
checks: check-aws_team_account
checks: check-mfa_token

lint:
	time ansible-lint *.yaml

_deploy: checks
	time ansible-playbook ${playbook} \
		--tags "${run_tags}" \
		--skip-tags "${skip_tags}" \
		-e PROFILE_TASKS_TASK_OUTPUT_LIMIT=100 \
		-i inventory \
		--extra-vars " \
			devops_operator=${devops_operator} \
			aws_team_account=${aws_team_account} \
			devops_operator_mfa_token=${mfa_token} \
		" 0</dev/null

product-aws-account-bootstrap: run_tags=product-aws-account-bootstrap
product-aws-account-bootstrap: skip_tags=destroy
product-aws-account-bootstrap: _deploy

destroy-product-aws-account-bootstrap: run_tags=destroy-product-aws-account-bootstrap
destroy-product-aws-account-bootstrap: _deploy

devops-account-bootstrap: run_tags=devops-account-bootstrap
devops-account-bootstrap: skip_tags=destroy
devops-account-bootstrap: _deploy

destroy-devops-account-bootstrap: run_tags=destroy-devops-account-bootstrap
destroy-devops-account-bootstrap: _deploy

destroy-all: run_tags=destroy
destroy-all: _deploy
