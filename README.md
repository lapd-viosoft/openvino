```sh
docker build -t centos-xfce-vnc .
docker run --user 0  -d -p 5901:5901 -p 6901:6901 centos-xfce-vnc
```
