# Stage 1: build Meteor and produce bundle
FROM node:18-bullseye AS builder
RUN apt-get update && apt-get install -y curl build-essential python3
# Install Meteor tool
RUN curl -sL https://install.meteor.com/ | sh

WORKDIR /app
COPY . /app

# Install app deps then build server-only bundle
RUN meteor npm install --production
RUN meteor build --directory /build --architecture os.linux.x86_64 --server-only

# Install node deps for the bundle's server programs
RUN cd /build/bundle/programs/server && npm install --production

# Stage 2: runtime image
FROM node:18-bullseye
WORKDIR /app
COPY --from=builder /build/bundle /app

ENV NODE_ENV=production
# Render automatically provides $PORT; Meteor respects process.env.PORT
EXPOSE 3000
CMD ["node", "main.js"]