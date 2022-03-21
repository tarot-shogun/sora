# SoraChat

This Python module wraps REST APIs to make it easier to use the SoraChat.

## Usage

```Python
sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
response = sorachat.tweet(r'Hello world!')
print response
```

## Requirement

### Module

- requests

### Unit Test

- httpretty
- parse
