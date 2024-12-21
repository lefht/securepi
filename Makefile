# Variables
DOCKER_IMAGE = custom-ansible
ANSIBLE_DIR = $(PWD)/ansible
PLAYBOOK = /ansible/playbooks/server.yaml
INVENTORY = /ansible/inventory/hosts


run:
	@docker run --rm -it \
		-v $(ANSIBLE_DIR):/ansible \
		-e ANSIBLE_HOST_KEY_CHECKING=False \
		$(DOCKER_IMAGE) \
		-i $(INVENTORY) $(PLAYBOOK)


build:
	@docker build -t $(DOCKER_IMAGE) .


clean:
	@rm -rf *.retry


help:
	@echo "Makefile for managing Ansible Docker container"
	@echo ""
	@echo "Targets:"
	@echo "  run     - Run the Ansible playbook"
	@echo "  build   - Build the Docker image"
	@echo "  clean   - Remove temporary files"
	@echo "  help    - Show this help message"
