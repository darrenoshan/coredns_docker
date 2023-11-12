# CoreDNS Docker Image Builder

This is a simple bash code to identify and download the latest version of [CoreDNS](https://coredns.io/)

## To install :
Steps :

```
git clone https://github.com/darrenoshan/coredns_docker && cd coredns_docker
bash ./docker_image_builder.sh
```


## using the docker-compose file :
Steps :

```
git clone https://github.com/darrenoshan/coredns_docker && cd coredns_docker
bash ./docker_image_builder.sh
echo '
.:53 {
    log
    errors
    file ./config/default.db
}
' > coredns1/config/Corefile

docker-compose -f docker-compose.yml up -d

```

