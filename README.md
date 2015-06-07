[![Build Status](http://img.shields.io/travis/cchurch/ansible-role-virtualenv.svg)](https://travis-ci.org/cchurch/ansible-role-virtualenv)
[![Galaxy](http://img.shields.io/badge/galaxy-cchurch.virtualenv-blue.svg)](https://galaxy.ansible.com/list#/roles/4061)

VirtualEnv
==========

Configure a Python virtualenv and install/update requirements.

Role Variables
--------------

The following variables may be defined to customize this role:

- `virtualenv_path`: Target directory in which to create/update virtualenv (required).
- `virtualenv_user`: User to become for updating the virtualenv (default is `ansible_ssh_user`).
- `virtualenv_default_os_packages`: Normally not needed to change unless running on a system using a different `ansible_pkg_mgr`, default is `{ apt: ['python-dev', 'python-virtualenv'], yum: ['python-devel', 'python-virtualenv'] }`.
- `virtualenv_os_packages`: OS packages to install to support the virtualenv, indexed by `ansible_pkg_mgr`, default is `{}`.
- `virtualenv_easy_install_packages`: Python packages to install globally using `easy_install`, default is `[]`.
- `virtualenv_easy_install_executable`: Alternate executable to use for global `easy_install` packages, default is `omit`.
- `virtualenv_global_packages`: Python packages to install globally using `pip`, default is `[]`.
- `virtualenv_pip_executable`: Alternate executable to use for global `pip` packages, default is `omit`.
- `virtualenv_command`: Alternate executable to use to create virtualenv, default is `omit`.
- `virtualenv_site_packages`: Boolean indicating whether virtualenv will use global site packages, default is `no`.
- `virtualenv_pre_packages`: Python packages to `pip` install in the virtualenv before requirements files, default is `[]`.
- `virtualenv_requirements`: List of requirements files to `pip` install in the virtualenv, default is `[]`.
- `virtualenv_post_packages`: Python packages to `pip` install in the virtualenv after requirements files, default is `[]`.
- `virtualenv_notify_on_updated`: Handler name to notify when the virtualenv was created or updated.

Each item in a package list above may be specified as a string with only the
package name or as a hash with `name`, `state` or `version` keys, e.g.:

    - package1
    - name: package2
      state: absent
    - name: package3
      version: 1.2

OS package lists are a hash indexed by the package manager, e.g.:

    apt:
      - package1
      - name: package2-dev
        state: absent
    yum:
      - package1
      - name: package2-devel
        state: absent
    foo_pkg_mgr:
      - foo-package1

Example Playbook
----------------

The following example playbook installs `libjpeg` as a system dependency,
creates or updates a virtualenv, installs specific packages, installs
requirements, then removes an old package no longer needed:

    - hosts: all
      roles:
        - role: cchurch.virtualenv
          virtualenv_path: ~/env
          virtualenv_os_packages:
            apt: ['libjpeg-dev']
            yum: ['libjpeg-devel]
          virtualenv_pre_packages:
            - name: Django
              version: 1.6.11
            - South
            - Pillow
          virtualenv_requirements:
            - ~/src/requirements.txt
          virtualenv_post_packages:
            - name: PIL
              state: absent
          virtualenv_notify_on_updated: virtualenv updated
      handlers:
        - name: virtualenv updated
          debug:
            msg: "virtualenv in {{virtualenv_path}} was updated."

License
-------

BSD

Author Information
------------------

Chris Church <chris@ninemoreminutes.com>
