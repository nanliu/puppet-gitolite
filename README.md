#modulename

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with [eshamow-gitolite]](#setup)
    * [What [eshamow-gitolite] affects](#what-[eshamow-gitolite]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with [eshamow-gitolite]](#beginning-with-[eshamow-gitolite])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Module to manage gitolite v3. There is no granular resource or ACL management - handles grabbing gitolite, installing where and under which user needed, and configuring a single public key for admin access.

##Module Description

Downloads and installs gitolite from git, or grabs .tar.gz or package to do the same, drops admin key, and operates the basic gitolite commands to initialize the admin repository.

Currently Supported:

RHEL 6
Debian 6 and 7
Ubuntu 12.04

Future support:

RHEL 5

##Setup

###What [eshamow-gitolite] affects

* By default, creates 'git' user and group and /home/git directory
* Populates homedir with expanded tarball or cloned git repo
* Places admin public key in this directory
* Executes gitolite install against /homedir/bin and gitolite setup against the public key

###Setup Requirements

* Expects 'git' binary to be installed/available. puppetlabs-git suffices for most systems.
* Time::HiRes perl module must be installed/available. manage_perl => true will attempt to install via package manager only.
  
###Beginning with [eshamow-gitolite]  

Classify node with gitolite and ensure that at a minimum key_user and pubkey parameters are configured in your Node Classifier or via data bindings.

##Limitations

RHEL or CentOS 6 only
