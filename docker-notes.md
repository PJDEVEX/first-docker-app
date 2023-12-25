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

### Remove containers and images

- `docker stop <ctn_name>` -  stop running ctn
- `docker rm <ctn_name>` - remove ctn
