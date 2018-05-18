# README #

This Ansible project can be used to setup various Ansible environments, e.g. UltraESB or ATG.

## Usage

Each application's deployment is done using a specific playbook file. Typical usage is as follows:

```
ansible-playbook -i [inventory_path] [playbook] -u [user] --private-key=[private-key]

playbook: one of the yml files in the root directory, e.g. besb.yml
inventory_path: the path inventories/[env].
                E.g. inventories/tst8 will take hosts and group vars from tst8.
user: the user to run the playbook as. Typically "ctier"
private-key: location of local PEM file to enable passwordless connectivity.

```

### Examples

*Doing a dry-run on tst8 for BESB*

```
ansible-playbook --check -i inventories/tst7 besb.yml
```

*Installing UltraESB for Backend ESB*

```
ansible-playbook -vvvv -i inventories/tst7 besb.yml -u ctier --private-key=/path/to/pem -b
```

## Tips

### Running as root

You might have to use `-b` (i.e `become` option) to execute commands as root. On older Ansible versions this is called `-s`.

### Permission errors
[reference.](https://github.com/ansible/ansible/issues/700#issuecomment-7286747)

If you face this issue you need to set `remote_tmp` in your `ansible.cfg` to point to /var/tmp/.ansible.

### "Check" mode (Dry Run)

When dealing with systems in real use, it is useful to *do a dry run first.* This will simulate a run and identify any problems with *syntax* and *connectivity*.

You can test your playbook using the `--check` option ( [reference](http://docs.ansible.com/ansible/playbooks_checkmode.html#check-mode-dry-run) ).

Example: For BESB setup

```
ansible-playbook --check besb.yml
```

### List Hosts

To only list the hosts that your playbook will run on, do

```
ansible-playbook --list-hosts [hosts file]
```
