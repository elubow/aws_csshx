# AWS CSSHX Wrapper

This is a wrapper script for ClusterSSHX (csshx).  It allows the user the ability to ssh to all machines in an AWS security group using a specific key and user for those machines.

## Installation

    gem install aws_csshx

### Configuration

The easist way to configure this gem is to add the following 4 lines to your _~/.csshrc_ (replace with your values):

    aws_region = us-east-1
    aws_access_key = AAAAAAAAAAAAAAAAAAAA
    aws_secret_key = TaaaaaLNiYbbbbbJm6uuqphcccccXtZydddddDfd
    ec2_private_key = /Users/elubow/.ssh/amazon.pem


### Examples

The most common use/case of _aws_csshx_ is to just ssh into a security group.
For instance, to SSH into the entire *utility* security group as *root*, do the following:

    aws_csshx -g 'utility' -l root

## Authors

 * Russell Bradberry <@devdazed>
 * Eric Lubow <@elubow>
