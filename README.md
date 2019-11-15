# talk.vanhack.ca Postfix Docker image

This is a Docker setup for a basic postfix/courier server. Currently limited to handling outgoing and incoming emails and one mailbox.

## Requirements

- Docker (18.x or higher)
- Docker Compose
 
## Configuration

Configure via `config` file from `config.sample` to generate secrets.

## Setup

```
./build.sh
```

## Starting

```
./start.sh
```

## Shell

```
./shell.sh
```

## Testing

```
./test.sh
```
