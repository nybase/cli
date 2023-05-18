
FROM alpine:3

ENV TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 UMASK=0022
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV k8s=v1.27.2 helm=v3.12.0 nerdctl=1.3.1  docker=24.0.0 

RUN set -eux; addgroup -g 8080 app ; adduser -u 8080 -S -G app -s /bin/bash app ;\
    case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo ${ARCH} ; export ARCH ;\
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories ;\
    #apk add --no-cache bash busybox-extras ca-certificates curl wget iproute2 iputils tzdata tmux ttf-dejavu tcpdump ;\
    wget -P /tmp -q -c dl.k8s.io/${k8s}/bin/linux/${ARCH}/kubectl https://get.helm.sh/helm-${helm}-linux-${ARCH}.tar.gz \
    https://github.com/containerd/nerdctl/releases/download/v${nerdctl}/nerdctl-full-${nerdctl}-linux-${ARCH}.tar.gz \
    http://mirrors.aliyun.com/docker-ce/linux/static/stable/$(uname -m)/docker-${docker}.tgz \
    http://mirrors.aliyun.com/docker-ce/linux/static/stable/$(uname -m)/docker-rootless-extras-${docker}.tgz ;\
    cp /tmp/kubectl /usr/local/bin/ ; chmod 755 /usr/local/bin/kubectl ;\
    tar zxfv /tmp/helm-${helm}-linux-${ARCH}.tar.gz -C /usr/local/bin/  --strip-components=1 ; \
    tar zxfv /tmp/docker-${docker}.tgz -C /usr/local/bin/ --strip-components=1 ; \
    tar zxfv /tmp/docker-rootless-extras-${docker}.tgz -C /usr/local/bin/ --strip-components=1 ; \
    tar zxfv nerdctl-full-${nerdctl}-linux-${ARCH}.tar.gz -C /usr/local/  ; \
    kubectl version;  helm version;nerdctl version;docker version; \
    rm -rf /tmp/* /var/cache/apk/*;
    

