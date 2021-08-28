# Bu dockerfile react'in artifact'i için hazırlanmıştır

FROM node:14 as build-deps

# Create app directory
WORKDIR /usr/src/app

COPY package.json yarn.lock ./

# this separates the dependency installation from the edits to our actual source files.
RUN yarn

# copy all files into the image
COPY . ./

# This will produce the ‘artifact’ inside of the build directory 
RUN yarn build

FROM nginx:alpine

COPY --from=build-deps /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


# Harika bir makale: Detaylı bu step'lerin açıklamaları buradan bulunabilir
# https://medium.com/@shakyShane/lets-talk-about-docker-artifacts-27454560384f