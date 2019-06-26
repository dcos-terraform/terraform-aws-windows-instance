FROM python:3.7-slim
RUN apt update && apt install -y --no-install-recommends openssh-client && rm -rf /var/lib/apt/lists/*
RUN pip install ansible==2.7.8 jmespath && pip install pywinrm==0.3.0