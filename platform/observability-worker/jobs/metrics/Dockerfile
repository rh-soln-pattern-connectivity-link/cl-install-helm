FROM --platform=linux/amd64 registry.access.redhat.com/ubi8/ubi


WORKDIR /workspace

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

COPY metrics.sh /usr/local/bin/metrics.sh
COPY patch.sh /usr/local/bin/patch.sh
COPY crb.yaml /workspace/crb.yaml
COPY sa.yaml /workspace/sa.yaml
COPY metrics-resources.yaml /workspace/metrics-resources.yaml