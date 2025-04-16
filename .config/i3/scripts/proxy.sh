#!/bin/bash
# 设置代理
function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

    if (( $# > 0 )); then
        valid=$(echo $@ | sed -n 's/\([0-9]\{1,3\}.\?\)\{4\}:\([0-9]\+\)/&/p')
        if [[ $valid != $@ ]]; then
            >&2 echo "Invalid address"
            return 1
        fi
        local proxy=$1
	echo $proxy
        export 	http_proxy="$proxy"\
               	https_proxy=$proxy \
               	ftp_proxy=$proxy   \
               	rsync_proxy=$proxy \
           	HTTP_PROXY=$proxy  \
	        HTTPS_PROXY=$proxy \
           	FTP_PROXY=$proxy   \
           	RSYNC_PROXY=$proxy
        echo "Proxy environment variable set."
        return 0
    fi

}

function proxy_off(){
    unset http_proxy https_proxy ftp_proxy rsync_proxy \
          HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY
    echo -e "Proxy environment variable removed."
}
set_proxy(){
	if [ -z $http_proxy ];then
		proxy_on '127.0.0.1:8080'
	else
		proxy_off
	fi
}
