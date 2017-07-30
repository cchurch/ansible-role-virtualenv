.PHONY: core-requirements update-pip-requirements requirements \
	galaxy-requirements syntax-check setup test cleanup clean-tox tox \
	bump-major bump-minor bump-patch

core-requirements:
	pip install "pip>=9,<9.1" setuptools "pip-tools>=1"

update-pip-requirements: core-requirements
	pip install -U "pip>=9,<9.1" setuptools "pip-tools>=1"
	pip-compile -U requirements.in

requirements: core-requirements
	pip-sync requirements.txt

galaxy-requirements: requirements
	ansible-galaxy install -f -p tests/roles -r tests/roles/requirements.yml

syntax-check: requirements
	ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook -i tests/inventory tests/main.yml --syntax-check

setup: requirements
	ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook -i tests/inventory -vv tests/setup.yml

test: requirements
	ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook -i tests/inventory -vv tests/main.yml

cleanup: requirements
	ANSIBLE_CONFIG=tests/ansible.cfg ansible-playbook -i tests/inventory -vv tests/cleanup.yml

clean-tox:
	rm -rf .tox

tox: requirements
	tox

bump-major:
	bumpversion major

bump-minor:
	bumpversion minor

bump-patch:
	bumpversion patch
