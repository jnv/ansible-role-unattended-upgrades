#!/bin/bash
#
# Based on the test shim by Jeff Geerling: https://gist.github.com/geerlingguy/73ef1e5ee45d8694570f334be385e181
# License: MIT
#
# Usage: [OPTIONS] ./tests/test.sh
#   - distribution: distribution to be tested (either "debian" or "ubuntu", default = "ubuntu")
#   - version: distribution version to be tested (default = "latest")
#   - playbook: a playbook in the tests directory (default = "test.yml")
#   - cleanup: whether to remove the Docker container (default = true)
#   - container_id: the --name to set for the container (default = timestamp)
#   - test_idempotence: whether to test playbook's idempotence (default = true)
#

# Exit on any individual command failure
set -e

# Ensure we are in the role's root dir
cd "$( dirname "${BASH_SOURCE[0]}" )/.."

# Pretty colors.
red='\033[0;31m'
green='\033[0;32m'
neutral='\033[0m'

timestamp=$(date +%s)

tests_dir='tests'
distribution=${distribution:-"ubuntu"}
version=${version:-"latest"}
cleanup=${cleanup:-"true"}
container_id=${container_id:-$timestamp}
test_idempotence=${test_idempotence:-"true"}
playbook=${playbook:-"test.yml"}

dockerfile=Dockerfile.${distribution}
docker_tag=${distribution}-${version}:ansible
# Path to playbook inside container
playbook_path=/etc/ansible/roles/role_under_test/${tests_dir}/${playbook}

printf ${green}"Building Docker container '${docker_tag}'"${neutral}"\n"
docker build --no-cache --rm --file=${tests_dir}/${dockerfile} --build-arg VERSION=$version --tag=${docker_tag} ./${tests_dir}
printf ${green}"Starting Docker container with name '${container_id}'"${neutral}"\n"
docker run --detach --volume="$PWD":/etc/ansible/roles/role_under_test:rw \
           --name $container_id \
           --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
           $docker_tag

printf ${green}"Checking Ansible playbook syntax"${neutral}"\n"
docker exec --tty $container_id env TERM=xterm ansible-playbook $playbook_path --syntax-check

printf ${green}"Running role"${neutral}"\n"
docker exec $container_id env TERM=xterm env ANSIBLE_FORCE_COLOR=1 ansible-playbook $playbook_path

if [ "$test_idempotence" = true ]; then
  # Run Ansible playbook again (idempotence test).
  printf ${green}"Idempotence test: Running playbook again"${neutral}"\n"
  idempotence=$(mktemp)
  docker exec $container_id ansible-playbook $playbook_path | tee -a $idempotence
  tail $idempotence \
    | grep -q 'changed=0.*failed=0' \
    && (printf ${green}'Idempotence test: pass'${neutral}"\n") \
    || (printf ${red}'Idempotence test: fail'${neutral}"\n" && exit 1)
fi

# Remove the Docker container (if configured).
if [ "$cleanup" = true ]; then
  printf "Removing Docker container...\n"
  docker rm -f $container_id
fi