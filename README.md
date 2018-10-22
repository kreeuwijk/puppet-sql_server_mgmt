
# sqlserver_mgmt

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Setup - The basics of getting started with sqlserver_mgmt](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sqlserver_mgmt](#beginning-with-sqlserver_mgmt)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This sqlserver_mgmt module builds on top of the puppetlabs/sqlserver module to provide the infrastructure as code needed to iterate over configuration in Hiera so you can easily manage resources on existing SQL servers (regardsless of whether Puppet was used to build the SQL server in the first place).

## Description

While the puppetlabs/sqlserver module provided powerful capabilities to manage Microsoft SQL Server, it lacks the code to quickly define some managed SQL resources in Hiera and have them be enforced by Puppet. While you could write Puppet code for each resource (which is what the puppetlabs/sqlserver module basically makes you do), this isn't very efficient nor fool-proof. Instead, using this module, a few lines of configuration in Hiera are all that's needs to manage SQL databases, logins, users and permissions.

## Setup

### Setup Requirements

Make sure you have the puppetlabs/sqlserver module and it's dependencies installed, before using this module.

By default, if you haven't created any configuration for this module in Hiera, this module will not enforce anything on your SQL servers.

### Beginning with sqlserver_mgmt

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
