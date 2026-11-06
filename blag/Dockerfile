FROM python:3.12-slim AS build
WORKDIR /site
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY pelicanconf.py publishconf.py ./
COPY content ./content
COPY gum ./gum
RUN pelican content -o output -s publishconf.py

FROM nginxinc/nginx-unprivileged:1.31-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /site/output /usr/share/nginx/html
EXPOSE 8080
