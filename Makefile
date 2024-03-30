# Variables
PYTHON_VERSION = $(shell cat .python-version)

.PHONY: build
build:
	@echo "Creating version control system..."
	@git init
	@git add .
	@echo "Creating virtual environment..."
	@poetry lock && poetry install
	@poetry run pre-commit install
	@echo "Done."

.PHONY: check
check:
	@echo "Checking Poetry lock file consistency with 'pyproject.toml': Running poetry check --lock"
	@poetry check --lock
	@echo "Running pre-commit checks..."
	@poetry run pre-commit run --all-files

.PHONY: clean-build
clean-build:
	@echo "Cleaning build..."
	@rm -rf dist

.PHONY: check-pyenv
check-pyenv:
	@echo "Checking if pyenv is installed..."
	@command -v pyenv >/dev/null 2>&1 || { echo >&2 " ------------- pyenv is not installed. Please install pyenv before proceeding."; exit 1; }
	@echo " ------------- pyenv is installed ------------- "

.PHONY: check-poetry
check-poetry:
	@echo "Checking if Poetry is installed..."
	@command -v poetry >/dev/null 2>&1 || { echo >&2 "Poetry is not installed. Please install Poetry before proceeding."; exit 1; }
	@echo " ------------- Poetry is installed ------------- "

.PHONY: install-python
install-python:
	@echo "Installing Python version $(PYTHON_VERSION) using pyenv"
	@pyenv install -s $(PYTHON_VERSION)

.PHONY: set-local-python
set-local-python:
	@echo "Setting local Python version to $(PYTHON_VERSION)"
	@pyenv local $(PYTHON_VERSION)

.PHONY: verify-python-version
verify-python-version:
	@echo "Verifying Python version..."
	@python --version | grep $(PYTHON_VERSION) || (echo "Invalid python version installed: $(python --version). Expected $(PYTHON_VERSION).*" && exit 1)
	@echo " ------------- Python version verified ------------- "

.PHONY: setup
setup: check-pyenv check-poetry install-python set-local-python verify-python-version build
	@echo " ------------- Setup completed ------------- "

.PHONY: verify-aws-credentials-exist
verify-aws-credentials-exist:
	@echo "Verifying AWS credentials..."
	@test -f ~/.aws/credentials || (echo "AWS credentials not found. Please configure AWS credentials before proceeding." && exit 1)
	@echo " ------------- AWS credentials verified ------------- "

.PHONY: deploy-terraform
deploy-terraform: verify-aws-credentials-exist
	@echo "Deploying Terraform..."
	@cd infrastructure/terraform && terraform init && terraform apply -auto-approve
	@echo " ------------- Terraform deployment completed ------------- "

.PHONY: destroy-terraform
destroy-terraform: verify-aws-credentials-exist
	@echo "Destroying Terraform..."
	@cd infrastructure/terraform && terraform destroy -auto-approve
	@echo " ------------- Terraform destruction completed ------------- "

.PHONY: run-app
run-app: deploy-terraform
	@echo "Running the application..."
	@cd producer/python/producer/ && poetry lock && poetry install
	@poetry run python producer/python/producer/producer/main.py --send_kinesis True --region_name us-west-2
	@echo " ------------- Application run completed ------------- "
