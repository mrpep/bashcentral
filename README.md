I run bash commands from many different computers. 

Sometimes I want to find a recent bash command and it's hard because first I need to find the computer where I ran it.

What if commands get logged into a single remote place and then I can use an UI to search commands from all my computers?

That's what bashcentral is about. The requisite is that you need a Nextcloud server where to store the logs.

### Prerequisites:
- Have a nextcloud instance accesible from the clients
- Install jq in the clients:
```
sudo apt-get install jq
```

### Usage:

- From the computers where you want to log:

```
bash install_client.sh
```

Follow instructions and you are done. 
Then reload terminal or:
```
source ~/.bashrc
```

Finally ensure that upload_nc.sh has execute permission, or run:
```
chmod +x upload_nc.sh
```

By default logs will get uploaded every minute, but you can configure that during installation.

- From one of the computers (or a different one), launch the API:

```
python app.py
```

- And then open the webpage ui.html. You'll see all the logs combined into a single table with search options :)
