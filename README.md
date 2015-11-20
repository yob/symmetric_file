# Symmetric File

A gem for reading and editing files encrypted with symmetric encryption.

##  Why?

Becauase reasons

## Installation

Like all gems:

    gem install symmetric_file

.. or just add it to your project Gemfile.

## Usage

This is a command line application. To create a new encypted file, or edit an existing one:

    bundle exec symmetric_file edit foo.txt.enc

To decrypt a file to stdout:

    bundle exec symmetric_file cat foo.txt.enc

To decrypt a file and redirect the output to an unencrypted file:

    bundle exec symmetric_file cat foo.txt.enc > foo.txt
