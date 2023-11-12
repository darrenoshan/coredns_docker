#!/usr/bin/bash
maindir="."
mkdir -p "$maindir/config/"

cd $maindir
touch $maindir/config/Corefile

dl_coredns_exec(){
    latest_release=`curl -Ls -o /dev/null -w %{url_effective} https://github.com/coredns/coredns/releases/latest/`
    latest_vesrion=`echo $latest_release | cut -d "/" -f8`
    latest_vesrion_num=`echo $latest_vesrion | grep -o "[0-9.]*"`

    # echo $latest_release
    # echo $latest_vesrion
    # echo $latest_vesrion_num

    curl -sL "https://github.com/coredns/coredns/releases/download/"$latest_vesrion"/coredns_"$latest_vesrion_num"_linux_amd64.tgz" -o $maindir/coredns_"$latest_vesrion_num"_linux_amd64.tgz
    tar -xf $maindir/coredns_"$latest_vesrion_num"_linux_amd64.tgz
}
create_dockerfile(){
    echo "FROM alpine:latest" > $maindir/Dockerfile
    echo "WORKDIR /coredns" >> $maindir/Dockerfile
    echo "COPY ./coredns /coredns/coredns" >> $maindir/Dockerfile
    echo "RUN chmod -R +x /coredns/coredns" >> $maindir/Dockerfile
    echo 'CMD ["/coredns/coredns","-conf","/coredns/config/Corefile"]' >> $maindir/Dockerfile
    echo "EXPOSE 53/tcp" >>  $maindir/Dockerfile
    echo "EXPOSE 53/udp" >>  $maindir/Dockerfile
}

generate_coredns_conf(){
    echo -e "* {\n\tforward 8.8.8.8\n\tlog\n\terrors\n\t}" | sed "s/\t/    /g"
    echo -e "localdomain.local {\n\tfile /coredns/config/local.db\n\tlog\n\terrors\n\t}" | sed "s/\t/    /g"
}
generate_rfc1035_conf(){
    echo "$TTL 14400"
    echo "@    IN    SOA    ns1.$DOMAIN.    root.$DOMAIN. ("
    echo "                                            2022010101"
    echo "                                            7200"
    echo "                                            3600"
    echo "                                            1209600"
    echo "                                            180 )"
    echo ""
    echo "@	      14400	IN	NS      ns1.$DOMAIN."
    echo "@	      14400	IN	NS	    ns2.$DOMAIN."
    echo "@	      14400	IN	A	    $IP"
    echo "ns1     14400	IN	A	    $IP"
    echo "ns2     14400	IN	A	    $IP"
    echo "www     14400	IN	A		$IP"
    echo "ftp	  14400	IN	A		$IP"
    echo ""
    echo "mail    14400	IN	A		$IP"
    echo "smtp    14400	IN	A		$IP"
    echo "pop     14400	IN	A		$IP"
    echo "imap    14400	IN	A		$IP"
    echo "@       14400	IN	MX	    10	mail.$DOMAIN."
    echo "@	      14400	IN	TXT		"v=spf1 a mx ip4:$IP ~all""
    echo "_dmarc  14400	IN	TXT		"v=DMARC1; p=none""
}

generate_coredns_conf > "$maindir/config/Corefile"
generate_rfc1035_conf > "$maindir/config/local.db"

dl_coredns_exec
create_dockerfile
docker build -f "$maindir/Dockerfile" -t mycoredns:$latest_vesrion_num "$maindir"
docker tag mycoredns:$latest_vesrion_num coredns:latest
echo -e "docker image built: \n mycoredns:$latest_vesrion_num \n\n coredns:latest "
