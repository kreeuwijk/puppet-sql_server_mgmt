
# sqlserver_mgmt

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Setup - The basics of getting started with sqlserver_mgmt](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sqlserver_mgmt](#beginning-with-sqlserver_mgmt)
4. [Usage - Configuration options and additional functionality](#usage)

## Overview

This sqlserver_mgmt module builds on top of the puppetlabs/sqlserver module to provide the infrastructure as code needed to iterate over configuration in Hiera so you can easily manage resources on existing SQL servers (regardsless of whether Puppet was used to build the SQL server in the first place).

## Description

While the puppetlabs/sqlserver module provided powerful capabilities to manage Microsoft SQL Server, it lacks the code to quickly define some managed SQL resources in Hiera and have them be enforced by Puppet. While you could write Puppet code for each resource (which is what the puppetlabs/sqlserver module basically makes you do), this isn't very efficient nor fool-proof. Instead, using this module, a few lines of configuration in Hiera are all that's needed to manage SQL databases, logins, users and permissions.

## Setup

### Setup Requirements

Make sure you have the puppetlabs/sqlserver module and it's dependencies installed, before using this module.

By default, if you haven't created any configuration for this module in Hiera, this module will not enforce anything on your SQL servers.

### Beginning with sqlserver_mgmt

To start managing resources on a SQL server, simply include the module in your profile:
```puppet
include sqlserver_mgmt
```

## Usage

Any SQL resources you wish to manage with this module, should be defined in Hiera. The module uses Automatic Parameter Lookup to automatically get data from Hiera if you have defined it. You can use any Hiera hierarchy structure you want, just be aware that by default, Hiera will use a first-match lookup to find the configuration resources. If you need to combine different configuration settings from different Hiera levels for the same resource section, you will need to configure the [lookup_options](https://puppet.com/docs/puppet/6.0/hiera_merging.html#concept-2997) for that key in Hiera to change the lookup behavior to Hash or Deep (depending on your needs).

There are 4 main resource sections to work with:
```puppet
sqlserver_mgmt::configs          # Defines administrative access info for each SQL instance
sqlserver_mgmt::databases        # Defines any databases you want to manage 
sqlserver_mgmt::logins           # Defines any SQL logins you want to manage
sqlserver_mgmt::users            # Defines any db users you want to manage, including permissions
```
And 3 optional sections to easily set defaults:
```puppet
sqlserver_mgmt::db_defaults      # defines default attributes for sqlserver_mgmt::databases
sqlserver_mgmt::login_defaults   # defines default attributes for sqlserver_mgmt::logins
sqlserver_mgmt::user_defaults    # defines default attributes for sqlserver_mgmt::users
```

Each of the 4 main sections allow you to dynamically create the respective SQL resource from the puppetlabs/sqlserver module. The supported attributes for each hash are the same as the attributes the puppetlabs/sqlserver module supports for the that respective resource.

For example if you configure this in Hiera:
```puppet
sqlserver_mgmt::configs:
  MSSQLSERVER:
    admin_login_type: SQL_LOGIN
    admin_user: sa
    admin_pass: password
```
it will result in the following resource to be created:
```puppet
sqlserver::config { 'MSSQLSERVER':
  admin_login_type => 'SQL_LOGIN',
  admin_user       => 'sa',
  admin_pass       => 'password',
}
```
With the sqlserver::config{'MSSQLSERVER'} resource, you are now able to connect to the MSSQLSERVER instance on the node and manage databases, logins and users.

Next, to manage databases, we can for example configure this in Hiera:
```puppet
sqlserver_mgmt::db_defaults:
  compatibility: 130
  instance: MSSQLSERVER

sqlserver_mgmt::databases:
  Sales:
    ensure: present
    instance: MYOTHERSQLSERVER
  Finance:
    ensure: absent
  Cortina:
    ensure: present
    compatibility: 120
```
and it will result in the following resources to be created:
```puppet
sqlserver::database{ 'Sales':
  ensure         => present,
  compatibility  => 130,
  instance       => 'MYOTHERSQLSERVER',
}
sqlserver::database{ 'Finance':
  ensure         => absent,
  compatibility  => 130,
  instance       => 'MSSQLSERVER',
}
sqlserver::database{ 'Cortina':
  ensure         => present,
  compatibility  => 120,
  instance       => 'MSSQLSERVER',
}
```
Of course to be able to manage the Sales database in this example, which lives on a different SQL instance, you'll need to add admin login credentials for MYOTHERSQLSERVER in `sqlserver_mgmt::configs`.

Managing logins works the same way. Defining this in Hiera:
```puppet
sqlserver_mgmt::login_defaults:
  instance: MSSQLSERVER
  login_type: WINDOWS_LOGIN
  default_database: master
  default_language: us_english

sqlserver_mgmt::logins:
  MYDOMAIN\User1:
  MYDOMAIN\User2:
    svrroles:
        dbcreator: 1
        sysadmin:  0
```
will result in the following resources to be created:
```puppet
sqlserver::login{ 'MYDOMAIN\User1':
  instance         => 'MSSQLSERVER',
  login_type       => 'WINDOWS_LOGIN',
  default_database => 'master',
  default_language => 'us_english',
}
sqlserver::login{ 'MYDOMAIN\User2':
  instance         => 'MSSQLSERVER',
  login_type       => 'WINDOWS_LOGIN',
  default_database => 'master',
  default_language => 'us_english',
  svrroles         => {
    dbcreator => 1,
    sysadmin  => 0,
  }
}
```
