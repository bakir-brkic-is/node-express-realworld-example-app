FROM node

ENV NODE_ENV=production
ENV MONGODB_URI=mongodb://localhost/conduit

RUN useradd nodeuser -m -d /usr/src/app

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package.json ./
COPY npm-shrinkwrap.json ./
RUN chown -R nodeuser: /usr/src/app

USER nodeuser
RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

EXPOSE 3000
CMD [ "node", "app.js" ]