# OpenARC

A functional reactive graph database backed by PostgreSQL

In layman's terms, OpenARC let's you build graphs of objects that react to one another.

# Getting Started

### Prerequisites

OpenARC requires Python 3+ and PostgreSQL 10+.

Consult your operating system documentation for details on how to install these requirements.

### Install OpenARC

Use `pip` to install the last release:

```sh
pip install openarc --user
```

Live on the edge by cloning our repository:

```sh
git clone https://www.github.com/kchoudhu/openarc
cd openarc
pip install . --user
```

### (Optional) Prepare database

If you don't already have a database to point to, you can use the makefile to spin up your own local instance to work with:

```sh
cd openarc
make dbmshardinit
```

### Configure OpenARC

Tell OpenARC where to find its configuration information:

```sh
export OPENARC_CFG_DIR=/config/lives/here
```

If ```OPENARC_CFG_DIR``` is not set, OpenARC will assume that its configuration is in the current directory.

OpenARC's configuration file is, unsurprisingly, called ```openarc.toml```. A sample file is available in the ```/cfg``` directory of the project distribution.

# Quickstart

### Define an object

Start by importing the library and defining an OAG class:

```python
class OAG_User(OAG_RootNode):
    @staticproperty
    def context(cls): return "myproject"

    @staticproperty
    def streams(cls): return {
        'username' : [ 'text', str(), None ],
        'password' : [ 'text', str(), None ]
    }

new_user =\
    OAG_User(initprms={
        'username' : 'kamil',
        'password' : 'hunter2'
    }, logger=logger)

print(new_user.username)

# Output: kamil
```

### Use the ORM

Persist to the database:

```python
new_user.db.create()
```

This creates a table in the database:

```SQL
> select * from myproject.user;

 _user_id | password | username
----------+----------+----------
        1 | hunter2  | kamil
```

Update the object:

```python
new_user[0].username = 'hana'
new_user.db.update()
```

The database is updated accordingly:

```SQL
> select * from myproject.user;

 _user_id | password | username
----------+----------+----------
        1 | hunter2  | hana
```

More documentation about the database capabilities of OpenARC is available here.

### Functional Reactive Programming

An ```OAG_Group``` is a collection of users:

```python
class OAG_Group(OAG_RootNode):
    @staticproperty
    def context(cls): return "myproject"

    @staticproperty
    def streams(cls): return {
        'user' : [ OAG_User, False, "user_update_handler" ]
    }

    def user_update_handler(self):
        print("[user_update_handler] User [%s] has been updated" % self.user.username)


group = OAG_Group()
group.user = new_user
```

An event dependency is created between ```group``` and ```new_user``` by assigning the latter to the former under ```group```'s  ```user``` node.

```user_update_handler``` is an event handler that is invoked whenever the ```user``` node of the OAG_Group object is changed:

```python
new_user.password = '*****'
# [user_update_handler] User [hana] has been updated
```

Nodes can be nested arbitrarily, permitting complex functional event chains. Think Excel, but for programmers.

# Next Steps

### Run the tests

If you have the project distribution, take a look under ```openarc/tests``` for a wide variety of use cases. Assuming your environment is set up, you can execute the tests by executing

```sh
make test
```

### Take a look at the examples

Interesting examples of OpenARC usage live under ```openarc/examples```. Each example is thoroughly documented and comes with a README; the hope is that they will open your eyes as to what is possible with OpenARC.

### Read the documentation

Documentation is distributed with the code, and can be generated by executing

```sh
make docs
```
