# Dockerfile for a basic web server
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
