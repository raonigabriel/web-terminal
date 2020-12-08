# web-terminal

## What is this?
This is a lightweight (~43MB) alpine based docker image that comes pre-packaged with 2 wonderful tools:
* [ttyd](https://github.com/tsl0922/ttyd): is a simple command-line tool for sharing a terminal over the web, using WebSockets.
* [ngrok](https://ngrok.com/): Creates reverse tunnels that allow access to your box from the internet.

On top of those, I've added socat, Nginx, OpenSSH, and OpenSSL. 
This allows you to quickly provision an isolated (docker container) that can serve as a base for a lot of tunneling solutions. Use your imagination. :wink:

If you run this with docker option **--rm** (as bellow), keep in mind that docker will remove the container once it gets stopped. This is good if you don't want to leave any garbage behind.

---
# Multi-Arch
This image supports the following architectures: linux/armv7, linux/arm64, linux/386 and linux/amd64.

This means you get it running on your RaspberryPi.

---
# Usage
```sh
# docker run --rm -d -p 7681:7681 raonigabriel/web-terminal:latest
```
Then access http://localhost:7681 to have a web-based shell. There is no enforced limit on the number of shells, but you can do that if needed, by customizing the ttyd daemon process.

See [here](https://github.com/tsl0922/ttyd#command-line-options) and [here](https://github.com/tsl0922/ttyd/wiki/Client-Options) for more help and the **CMD** line of this image's Dockerfile.

---
# Advanced Usage
Things start shining when you pair ttyd with ngrok. On one active shell, start nrgrok:

```sh
ngrok http -region=sa -bind-tls=true -inspect=false localhost:7681
```
Check its running:
```
ngrok by @inconshreveable
Session Status                online
Session Expires               7 hours, 59 minutes
Version                       2.3.35
Region                        South America (sa)
Forwarding                    https://e0075a2a0966.ngrok.io -> http://localhost:7681
```

See the **Forwarding** line? You now have your docker-container, web-based ttyd shell exposed (over HTTPS) by ngrok to the Internet.

Notice that on this example weŕe using a custom region (sa) and that weŕe only exposing HTTPS tunnel (no HTTP) and that we have disabled the ngrok admin console (usually it listens on port 4040).

Now, let's try that with nginx. First, run the embedded nginx in the background (notice the ampersand) then start ngrok:
```sh
# nginx &
# ngrok http 80

ngrok by @inconshreveable
Session Status                online
Session Expires               7 hours, 59 minutes
Version                       2.3.35
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://cf96bd9d722e.ngrok.io -> http://localhost:80
Forwarding                    https://cf96bd9d722e.ngrok.io -> http://localhost:80 
```
And now you have your nginx exposed to the internet over HTTP and HTPS (there are 2 **Forwarding** mappings).
On this example, the web interface is also enabled on port 4040.

Keep in mind that you can also use any other TCP based service server because ngrok supports not only HTTP/HTTPS but also raw TCP tunnels.

---
## Extras
To terminate the container (and all its shells) from inside, run this aliased version of **poweroff**:
```sh
# poweroff
```
It **WILL NOT** shut down the host, but the container instead. 

---
## Docker options (ports and volumes)
By default, ttyd runs on port 7681 and ngrok opens and admin console on port 4040.

If you want to have access to the ngrok admin console, remember to add **-p 4040:4040** to the docker call:
```sh
# docker run --rm -d -p 4040:4040 -p 7681:7681 raonigabriel/web-terminal:latest
```

If you know you will need access to the container internal ports, (nginx, openssh-server) just use add **-p** to the docker call, for an example:
```sh
# docker run --rm -d -p 80:80 -p 7681:7681 raonigabriel/web-terminal:latest
```

If you want to keep the container after it exits, remove the **--rm** from the call:
```sh
# docker run -d -p 7681:7681 raonigabriel/web-terminal:latest
```

If you want to use any volume(s) from the host, just bind mount it with **-v**, for an example:
```sh
# docker run --rm -d -v /var/run/docker.sock:/var/run/docker.sock -p 7681:7681 raonigabriel/web-terminal:latest
```

---
## Custom (derived) image
You can create your own custom Docker image, inherit from this one then add the tools you want and a non-root user (recomended). See the sample **Dockerfile** bellow for a custom developer image tha could be used as standard-sandboxed-environment by javascript developers:
```docker
FROM raonigabriel/web-terminal:latest
RUN apk add --no-cache curl nano git g++ make npm docker-cli && \
    npm install -g yarn typescript @angular/cli && \
    addgroup -g 1000 docker && \
    adduser -s /bin/sh -u 1000 -D -G docker developer && \
    mkdir /home/developer/.ngrok2 && \
    echo "web_addr: 0.0.0.0:4040" > /home/developer/.ngrok2/ngrok.yml && \
    echo "tunnels:" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "  nodejs:" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "    proto: http" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "    addr: 3000" >> /home/developer/.ngrok2/ngrok.yml && \
    chown -R developer:docker /home/developer/.ngrok2

USER developer
WORKDIR /home/developer
CMD [ "ttyd", "-c", "developer:password", "-s", "3", "-t", "titleFixed=/bin/sh", "-t", "rendererType=webgl", "-t", "disableLeaveAlert=true", "/bin/sh", "-i", "-l" ]
``` 
Build, then run it:
 ```sh
# docker build . -t js-box
# docker run --rm --hostname jsbox -d -p 7681:7681 js-box
```
Because we configured the **~/.ngrok2/ngrok.yml** on this custom image, you can start the ngrok tunnel by name inside the container as follows:
 ```sh
# ngrok start nodejs
```

And since this image has the docker-cli, you could even bind-mount the host docker socket to use it from inside the container: 
 ```sh
# docker run --rm --hostname jsbox -v /var/run/docker.sock:/var/run/docker.sock -d -p 7681:7681 js-box
```
We could also use have used socat, openssh tunnels or event ngrok to forward the local docker port (2375) to another host.

---
## ngrok account and plans
ngrok suports TLS, TCP tunnels, certs, built-in fileserver, forwarding to other machines so please take a look on https://ngrok.com/docs for more help.

Keep in mind that some of the advanced features require you to create a (free) account then use the provided auth token. See https://ngrok.com/docs#getting-started-authtoken for more info.

ngrok is free but also has paid plans that allow custom domains, reserved tunnels and greater control. See https://ngrok.com/pricing for plans.

---
## Licenses

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

---
## Disclaimer
* I am not affiliated in any way with ngrok.
* This image comes with no warranty. Use it at your own risk.
* I don't like Apple. Fuck off, fan-boys.
* I don't like left-winged snowflakes. Fuck off, code-covenant. 
* I will call my branches the old way. Long live **master**, fuck-off renaming.