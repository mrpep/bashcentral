I run bash commands from many different computers. 

Sometimes I want to find a recent bash command and it's hard because first I need to find the computer where I ran it.

What if commands get logged into a single remote place and then I can use an UI to search commands from all my computers?

That's what bashcentral is about. The requisite is that you need a Nextcloud server where to store the logs.

### Usage:

- From the computers where you want to log:

```
bash install_client.sh
```

Follow instructions and you are done. By default logs will get uploaded every minute, but you can configure that during installation.

- From one of the computers (or a different one), launch the UI:
