FROM nginx:1.25-alpine

RUN apk add --no-cache python3 py3-pip py3-boto3

COPY nginx.conf /etc/nginx/nginx.conf
COPY worker_awakener.py /usr/local/bin/worker_awakener.py

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
