#!/bin/bash

docker run --rm --entrypoint htpasswd registry:2 -Bbn admin admin > auth/htpasswd

#docker run -d -p 5000:5000 -v /root/registry-docker/data:/var/lib/registry -v /root/registry-docker/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry:2

docker run --rm -e COMMON_NAME=pek2-office-9th-10-117-169-121.eng.vmware.com -e KEY_NAME=domain -v /root/registry-docker/certs:/certs centurylink/openssl

mkdir -p /etc/docker/certs.d/pek2-office-9th-10-117-169-121.eng.vmware.com:5000

#this crt also could copy to other host which want to pull and push image from branw.com:5000
#sudo scp root@10.117.169.121:/root/registry-docker/certs/domain.crt /etc/docker/certs.d/branw.com\:5000/ca.crt
cp /root/registry-docker/certs/domain.crt /etc/docker/certs.d/pek2-office-9th-10-117-169-121.eng.vmware.com\:5000/ca.crt

docker run -d --name registry -p 5000:5000 -v /root/registry-docker/data:/var/lib/registry -v /root/registry-docker/auth:/auth -v /root/registry-docker/certs:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry:2

docker login -u admin -p admin pek2-office-9th-10-117-169-121.eng.vmware.com:5000

docker tag ubuntu pek2-office-9th-10-117-169-121.eng.vmware.com:5000/ubuntu:firstimage

docker push pek2-office-9th-10-117-169-121.eng.vmware.com:5000/ubuntu:firstimage


#use registry ui
docker run -d --name registry-ui -p 8080:8080 --link registry -e REGISTRY_URL=https://10.117.169.121:5000/v2 -e REGISTRY_TRUST_ANY_SSL=true -e REGISTRY_BASIC_AUTH="YWRtaW46YWRtaW4=" -e REGISTRY_NAME=10.117.169.121:5000 hyper/docker-registry-web

curl --cacert /root/registry-docker/certs/domain.crt -u admin:admin  https://10.117.169.121:5000/v2/_catalog



#Simple registry without certificate and base authenticate
docker run -d -p 5000:5000 --restart=always --name registry registry:2
docker run -d -p 5000:5000 -v /root/registry-docker/data:/var/lib/registry --restart=always --name registry registry:2
docker run -d -p 8080:8080 --name registry-ui --link registry -e REGISTRY_URL=http://registry:5000/v2 -e REGISTRY_NAME=localhost:5000 hyper/docker-registry-web
docker pull ubuntu && docker tag ubuntu localhost:5000/ubuntu
docker push localhost:5000/ubuntu
docker pull localhost:5000/ubuntu
docker stop registry && docker rm -v registry
#over


curl --cacert /etc/docker/certs.d/pek2-office-9th-10-117-169-121.eng.vmware.com\:5000/ca.crt -u admin:admin  https://pek2-office-9th-10-117-169-121.eng.vmware.com:5000/v2/_catalog

docker login -u admin -p admin pek2-office-9th-10-117-169-121.eng.vmware.com:5000

scp root@10.117.169.121:/etc/docker/certs.d/pek2-office-9th-10-117-169-121.eng.vmware.com\:5000/ca.crt .


