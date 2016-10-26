# talk.vanhack.ca Postfix Docker image

This is a Dockerfile for a basic postfix/courier server. Currently it's just for incoming emails and just has a single mailbox.

## Setup

Generate your DKIM key and place the private in ./opendkim.private

Assuming docker is installed:

```
./build.sh
```

This will download and build the image to run, if you make any changes then re-run.

## Starting

```
./start.sh <password>
```
This will create an instance and run it. The password is for the discourse account used for pop3 access. 
