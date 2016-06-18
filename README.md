[![Build Status](http://img.shields.io/travis/cchurch/ansible-role-virtualenv.svg)](https://travis-ci.org/cchurch/ansible-role-virtualenv)
[![Galaxy](http://img.shields.io/badge/galaxy-cchurch.virtualenv-blue.svg)](https://galaxy.ansible.com/cchurch/virtualenv/)

VirtualEnv
==========

Configure a Python virtualenv and install/update requirements. Requires Ansible 1.9 or later.

Requirements
------------

When `become` is used (`virtualenv_user` does not equal `ansible_ssh_user`),
the necessary OS package(s) to support `become_method` (e.g. `sudo`) must be
installed before using this role.

When neither `ansible_ssh_user` or `ansible_become_user` is `root`, the
necessary OS package(s) to provide the `virtualenv` command must be installed
before using this role.

Role Variables
--------------

The following variables may be defined to customize this role:

- `virtualenv_path`: Target directory in which to create/update virtualenv (required).
- `virtualenv_user`: User to become for creating/updating the virtualenv (default is `ansible_ssh_user`).
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
- `virtualenv_notify_on_updated`: Handler name to notify when the virtualenv was created or updated. This variable must be defined at the play/task level; defining it via inventory or `set_fact` will not work.
- `virtualenv_recreate`: Boolean indicating whether to delete and recreate virtualenv, default is `no`.

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

This role can create a virtualenv as another user, specified by `virtualenv_user`,
and will use the `become_method` specified for the host/play/task. OS and global
packages will only be installed when `ansible_ssh_user` or `ansible_become_user`
is `root`. The following example combinations of users are listed below with
their expected results:

- `ansible_ssh_user=root`: OS and global packages will be installed; virtualenv will be owned by `root`.
- `ansible_ssh_user=root virtualenv_user=other`: OS and global packages will be installed; `become` will be used; virtualenv will be owned by `other`.
- `ansible_ssh_user=other`: OS and global packages will *not* be installed; virtualenv will be owned by `other`.
- `ansible_ssh_user=other virtualenv_user=another`: OS and global packages will *not* be installed; `become` will be used; virtualenv will be owned by `another`. This combination may fail if `other` cannot become `another`. The Ansible 2.1 note below may also apply.
- `ansible_ssh_user=other ansible_become_user=root`: OS and global packages will be installed; `become` will be used; virtualenv will be owned by `other`.
- `ansible_ssh_user=other ansible_become_user=root virtualenv_user=another`: OS and global packages will be installed; `become` will be used; virtualenv will be owned by `another`. When using Ansible 2.1 and later, you may need to define `allow_world_readable_tmpfiles` in your `ansible.cfg` or use another approach to support becoming an unprivileged user.

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
              version: 1.8.13
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

Chris Church (chris@ninemoreminutes.com)
