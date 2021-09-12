FROM node

ENV NODE_ENV=production
# ENV MONGODB_URI=mongodb://localhost/conduit

RUN useradd nodeuser -m -d /usr/src/app

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json ./
COPY npm-shrinkwrap.json ./
RUN chown -R nodeuser: /usr/src/app
USER nodeuser
RUN npm install --only=production

# Bundle app source
COPY . .

EXPOSE 2000
CMD [ "node", "app.js" ]