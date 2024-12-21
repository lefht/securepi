FROM ubuntu:latest

# Install prerequisites
RUN apt-get update && \
    apt-get install -y python3 python3-pip sshpass && \
    pip3 install --break-system-packages ansible && \
    apt-get clean

# Create a directory for Ansible
RUN mkdir -p /ansible

WORKDIR /ansible

# Add a default entrypoint
ENTRYPOINT ["ansible-playbook"]