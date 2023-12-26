# commands

## Create docker network

`
docker network create <new_network_name>
`
<br>

e.g.: `docker network create mongo-network`

## Start mongodb
```bash
docker run -d \
-p 27017:27017 \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=password \
--name mongodb \
--net mongo-network \
mongo
```
<br>

## start mongo-express
- In the blow `ME_CONFIG_MONGODB_SERVER` is critical
- Should include the usename and password for mongo-express as well
- Otherwise, will not be able to login to the express GUI

```bash
docker run -d \
-p 8081:8081 \
--name mongo-express \
--net mongo-network \
-e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
-e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
-e ME_CONFIG_MONGODB_SERVER=mongodb \
-e ME_CONFIG_BASICAUTH_USERNAME=mg-ex-admin \
-e ME_CONFIG_BASICAUTH_PASSWORD=password \
mongo-express
```
## Docker compose
- indentation is important
- all the images should be in same line
- they config shall be inside

### Run the docker-compose

`/home/pjlinux/first-docker-app/mongo.yaml`

```yaml
version: '3'

services:
  # my-app:
  #   image: ${docker-registry}/my-app:1.0
  #   ports:
  #     - 3000:3000

  mongodb:
    image: mongo
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
    # volumes:
    #   - mongo-data:/data/db

  mongo-express:
    image: mongo-express
    # restart: always # fixes MongoNetworkError when mongodb is not ready when mongo-express starts
    ports:
      - 8080:8081
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=password
      - ME_CONFIG_MONGODB_SERVER=mongodb
      - ME_CONFIG_BASICAUTH_USERNAME=mg-ex-admin
      - ME_CONFIG_BASICAUTH_PASSWORD=password

# volumes:
#   mongo-data:
#     driver: local
```
`docker-compose -f <yamal_file> up` <br>

`docker-compose -f mongo.yaml up`
- `f` - file
- `up` - start all the ctn inside the yamal file

<br>

**Outcome**
- docker-compose has created the docker network, ctns, runs and connected them
- NOTE: docker-compse has changed the mongo-express port to 8081
- You need to open the mongo-ex in 8080 in computer but forward the request to ctn in port 8081

**Note:** 
everytime docker-compose restart,
- will lose the data
- the data persistance will be addressed by __volume__


 ```ubuntu
 pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$ docker-compose -f mongo.yaml up
[+] Running 3/3
 ✔ Network first-docker-app_default            Created                                                                   0.6s
 ✔ Container first-docker-app-mongo-express-1  Created                                                                   0.7s
 ✔ Container first-docker-app-mongodb-1        Created                                                                   0.8s
Attaching to mongo-express-1, mongodb-1
 ```

 ```Ubuntu
 pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
pjlinux@DESKTOP-OTE9RM3:~$ docker network ls
NETWORK ID     NAME                       DRIVER    SCOPE
6f6791286299   bridge                     bridge    local
5e5e62981945   first-docker-app_default   bridge    local
ec8cf2175142   host                       host      local
feae760d7442   mongo-network              bridge    local
2d96cfffd178   none                       null      local
pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS                      NAMES
d1352a0b7aa6   mongo-express   "/sbin/tini -- /dock…"   4 minutes ago   Up 4 minutes   0.0.0.0:8080->8081/tcp     first-docker-app-mongo-express-1
3d4e24f35f42   mongo           "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   0.0.0.0:27017->27017/tcp   first-docker-app-mongodb-1
pjlinux@DESKTOP-OTE9RM3:~$

 ```

### Shutdowm all the network and containers - using docker-compse
`docker-compose -f mongo.yaml down`
- Shut down (stop and remove) the network and all the containers

```Ubuntu

pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$ docker-compose -f mongo.yaml down
[+] Running 3/3
 ✔ Container first-docker-app-mongo-express-1  Removed                                                                   1.2s
 ✔ Container first-docker-app-mongodb-1        Removed                                                                   1.3s
 ✔ Network first-docker-app_default            Removed                                                                   0.3s
pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$
```

```ubuntu
pjlinux@DESKTOP-OTE9RM3:~$ docker network ls
NETWORK ID     NAME            DRIVER    SCOPE
6f6791286299   bridge          bridge    local
ec8cf2175142   host            host      local
feae760d7442   mongo-network   bridge    local
2d96cfffd178   none            null      local
pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
pjlinux@DESKTOP-OTE9RM3:~$
```
### Remove containers and images

- `docker stop <ctn_name>` -  stop running ctn
- `docker rm <ctn_name>` - remove ctn

## Create own docker file

It is better to define the env variables externally in a docker-compose file. 
They can be easily modified

|Image env blueprint| Dockerfile| comment|
|---|---|---|
|install node | ```FROM node```| start basing it on another image |
|set env variables | <code> ENV MONGO_DB_USERNAME=admin \ MONGO_DB_PASSWORD=password </code>| It is better to define the env variables externally in a docker-compose file. They can be easily modified |
|create/home/app folder | ```RUN mkdir -p home/app```| Using __Run__- canexecute any Linux command. The directory created inside a ctn, __NOT__ on laptop or host!|
|copy current folders/ files to home/app|   `COPY . /home/app`|__COPY__ commnads are execute on the __HOST__machine:exclamation: __.__: source __/home/app__: target, You can copy files in the host to the inside of the ctn image(/home/app)  |
|star the app with: "node server.js | ```CMD ["node","server.js"]```|Execute entry point Linux commands. This can be done becuase `Node` is pre-installed because of base image|

### RUN vs CMD
- `CMD` = entry point command. Can have only ONCE
- `RUN` = can have multiple times in dockerfile

__Dockerfile__

- __NOTE__ __:__ Every base image is based on another Dockerfile
e.g.: Node:20-alpine3.18 is buit on [its owned Dockerfile](https://github.com/nodejs/docker-node/blob/9ee59bf646e8be3ff6ae849e8119312f198be55c/21/alpine3.18/Dockerfile).

__Image layers__
| <p align="center">Image</p> |
| --- |
| <p align="center"><span style="color:red; font-size:18px;">&#9650;</span></p> |
| <p align="center">Node:20-alpine3.18 </p> |
| <p align="center"><span style="color:red; font-size:18px;">&#9650;</span></p> |
| <p align="center">alpine:3.18 </p>|
||

```Dockerfile
FROM node:20-alpine3.18

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PASSWORD=passoword

RUN mkdir /home/app

COPY . /home/app

CMD ["node", "server.js"]

```

__Create Docker image__<br>
`docker build -t <image_name:tag or version> <location>`

e.g.: `pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$ docker build -t first-docker-app:1.0 .`

- command to be executed in __project__ directory
- `-t` : name of the image
- `.`: in current directory

__Rebuilding a docker image__
if you find an error in the process, need to follow the below step to delete a docker image

- e.g.: 
- Due to the wrong location of the server.js file, docker run cannot be execurted correctly.
- So need to rebuild the image

```bash
pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$ docker run first-docker-app:1.0
node:internal/modules/cjs/loader:1147
  throw err;
  ^

Error: Cannot find module '/server.js'
    at Module._resolveFilename (node:internal/modules/cjs/loader:1144:15)
    at Module._load (node:internal/modules/cjs/loader:985:27)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:135:12)
    at node:internal/main/run_main_module:28:49 {
  code: 'MODULE_NOT_FOUND',
  requireStack: []
}

Node.js v20.10.0
```

Correct the PATH


1. Correct the path
```Dockerfile 
CMD ["node", "/home/app/server.js"]
```
2. First, remove the ctn before image. Otherwise,

```bash 
pjlinux@DESKTOP-OTE9RM3:~$ docker rmi e13d81857488
Error response from daemon: conflict: unable to delete e13d81857488 (must be forced) - image is being used by stopped container c4a59b347ccb 
```

3. Remove ctn
```docker rm <ctn_no>```

```bash

pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY          TAG     IMAGE ID       CREATED          SIZE
first-docker-app    1.0     e13d81857488   6 minutes ago    166MB

pjlinux@DESKTOP-OTE9RM3:~$ docker ps -a | grep first-docker-app
c4a59b347ccb   first-docker-app:1.0                                                                    "docker-entrypoint.s…"   4 minutes ago   Exited (1) 4 minutes ago             elated_aryabhata
pjlinux@DESKTOP-OTE9RM3:~$ docker rm c4a59b347ccb
c4a59b347ccb
```

4. Remove the img
```docker rmi <img_#>```
```bash

pjlinux@DESKTOP-OTE9RM3:~$ docker rmi e13d81857488
Untagged: first-docker-app:1.0
Deleted: sha256:e13d81857488f19b02f5221e39eecac7cbfaaec37295259d021ef3f0cdc34ecf
```
