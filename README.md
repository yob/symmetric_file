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

## Git Integration

By default, files encrypted with symmetric\_file don't play well with Git. They're
base64 encoded, so git will attempt to handle merging the encrypted data and mangle it.

symmetric\_file has some helpers that make it possible to merge changes to an encrypted
file, however it requires some configuration of your git repo.

First, add a .gitattributes file to the repo with the following content. This file
can be tracked in git and shared with collaborators.

```
*.enc diff=enc merge=enc
```

Second, edit .git/config and add the following content. This file is specific to the
local repo and is not shared with collaborators.

```
[diff "enc"]
  textconv = bundle exec symmetric-file cat
[merge "enc"]
  name = symmetric-file merge driver
  driver = "bundle exec symmetric-file merge %O %A %B"
```

This will lead to the following behaviour:

A `git diff` that includes changes to an encrypted file will prompt for the
passphrase and then display a diff of the decrypted content.

A `git merge` that involves changes to an encrypted file prompt for the
passphrase. If an automated merge of the decrypted content is possible, there's
nothing left to do. If an automated merge wasn't possible, then the file will
be re-encrypted with merge conflict markers and they can be resolved manually
before commiting the merge.
