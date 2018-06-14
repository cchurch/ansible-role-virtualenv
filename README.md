[![Build Status](http://img.shields.io/travis/cchurch/ansible-role-virtualenv.svg)](https://travis-ci.org/cchurch/ansible-role-virtualenv)
[![Galaxy](http://img.shields.io/badge/galaxy-cchurch.virtualenv-blue.svg)](https://galaxy.ansible.com/cchurch/virtualenv/)

VirtualEnv
==========

Configure a Python virtualenv and install/update requirements. Requires Ansible
2.0 or later.

Requirements
------------

When `become` is used (i.e. `virtualenv_user` does not equal `ansible_user` or
`ansible_ssh_user`), the necessary OS package(s) to support `become_method`
(e.g. `sudo`) must be installed before using this role.

When none of `ansible_user`, `ansible_ssh_user` or `ansible_become_user` is
`root`, the necessary OS package(s) to provide the `virtualenv` command must be
installed by some other means before using this role.

Role Variables
--------------

The following variables may be defined to customize this role:

- `virtualenv_path`: Target directory in which to create/update virtualenv
  (required).
- `virtualenv_user`: User to become for creating/updating the virtualenv;
  default is `ansible_user` or `ansible_ssh_user`.
- `virtualenv_default_os_packages`: OS packages required in order to create a
  virtualenv. There is usually no need to change this option unless running on a
  system using a different `ansible_pkg_mgr`; default is
  `{ apt: ['python-dev', 'python-virtualenv'], yum: ['python-devel', 'python-virtualenv'] }`.
- `virtualenv_os_packages`: OS packages to install to support the virtualenv,
  indexed by `ansible_pkg_mgr`; default is `{}`.
- `virtualenv_easy_install_packages`: Python packages to install globally using
  `easy_install`; default is `[]`.
- `virtualenv_easy_install_executable`: Alternate executable to use for global
  `easy_install` packages; default is `omit` to use the `easy_install` command
  found in the path.
- `virtualenv_global_packages`: Python packages to install globally using `pip`;
  default is `[]`.
- `virtualenv_pip_executable`: Alternate executable to use for global `pip`
  packages; default is `omit` to use the `pip` command found in the path.
- `virtualenv_command`: Alternate executable to use to create virtualenv;
  default is `omit` to use `virtualenv` command found in the path.
- `virtualenv_default_package`: Default package to install when creating the
  virtualenv; default is `wsgiref`. Another package will need to be used for
  Python 3.x.
- `virtualenv_site_packages`: Boolean indicating whether virtualenv will use
  global site packages; default is `no`.
- `virtualenv_pre_packages`: Python packages to `pip` install inside the
  virtualenv before requirements files; default is `[]`. This option can also be
  used to remove packages no longer needed in the virtualenv.
- `virtualenv_requirements`: List of requirements files to `pip` install inside
  the virtualenv; default is `[]`. These paths must already be present on the
  remote system.
- `virtualenv_post_packages`: Python packages to `pip` install inside the
  virtualenv after requirements files; default is `[]`. This option can also be
  used to remove packages no longer needed in the virtualenv.
- `virtualenv_recreate`: Boolean indicating whether to delete and recreate the
  virtualenv; default is `no`.

The following variable may be defined for the play or role invocation (but not
as an inventory group or host variable):

- `virtualenv_notify_on_updated`: Handler name to notify when the virtualenv
  was created or updated.

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

This role can create a virtualenv as another user, specified by
`virtualenv_user`, and will use the `become_method` specified for the
host/play/task. OS and global packages will only be installed when
`ansible_user`, `ansible_ssh_user` or `ansible_become_user` is `root`. The
following example combinations of users are listed below with their expected
results:

- `ansible_user=root`: OS and global packages will be installed; virtualenv will
  be owned by `root`.
- `ansible_user=root virtualenv_user=other`: OS and global packages will be
  installed; `become` will be used; virtualenv will be owned by `other`.
- `ansible_user=other`: OS and global packages will *not* be installed;
  virtualenv will be owned by `other`.
- `ansible_user=other virtualenv_user=another`: OS and global packages will
  *not* be installed; `become` will be used; virtualenv will be owned by
  `another`. This combination may fail if `other` cannot become `another`. The
  Ansible 2.1 note below may also apply in this case.
- `ansible_user=other ansible_become_user=root`: OS and global packages will be
  installed; `become` will be used; virtualenv will be owned by `other`.
- `ansible_user=other ansible_become_user=root virtualenv_user=another`: OS and
  global packages will be installed; `become` will be used; virtualenv will be
  owned by `another`. When using Ansible 2.1 and later, you may need to define
  `allow_world_readable_tmpfiles` in your `ansible.cfg` (which still still
  generate a warning instead of an error) or use another approach to support one
  unprivileged user becoming another unprivileged user.

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
            apt: [libjpeg-dev]
            yum: [libjpeg-devel]
          virtualenv_pre_packages:
            - name: Django
              version: 1.8.18
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
            msg: 'virtualenv in {{virtualenv_path}} was updated.'

License
-------

BSD

Author Information
------------------

Chris Church ([cchurch](https://github.com/cchurch))
