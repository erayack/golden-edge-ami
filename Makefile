PACKER_DIR := packer
TF_DIR := terraform/envs/dev

.PHONY: validate packer-init packer-validate packer-build terraform-init terraform-validate terraform-plan terraform-apply wait publish rollback shellcheck

validate: shellcheck packer-init packer-validate terraform-init terraform-validate
	ansible-galaxy collection install -r ansible/requirements.yml -p .ansible/collections --force
	if command -v ansible-lint >/dev/null 2>&1; then ansible-lint ansible/playbook.yml; else echo "ansible-lint not installed"; exit 1; fi

shellcheck:
	shellcheck scripts/*.sh

packer-init:
	cd $(PACKER_DIR) && packer init .

packer-validate:
	cd $(PACKER_DIR) && packer fmt -check . && packer validate .

packer-build:
	cd $(PACKER_DIR) && packer build -machine-readable .

terraform-init:
	cd $(TF_DIR) && terraform init -backend=false

terraform-validate:
	cd $(TF_DIR) && terraform fmt -check -recursive && terraform validate

terraform-plan:
	cd $(TF_DIR) && terraform plan

terraform-apply:
	cd $(TF_DIR) && terraform apply

wait:
	@ASG_NAME="$$(cd $(TF_DIR) && terraform output -raw asg_name)"; \
	./scripts/wait-for-refresh.sh "$$ASG_NAME"

publish:
	@test -n "$(AMI_ID)" || (echo "usage: make publish AMI_ID=ami-..." >&2; exit 64)
	./scripts/publish-ami.sh "$(AMI_ID)"

rollback:
	./scripts/rollback-ami.sh
