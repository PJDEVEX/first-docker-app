# commands

## Create docker network

`docker network create <new_network_name>`
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
version: "3"

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
- the data persistance will be addressed by **volume**

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

- `docker stop <ctn_name>` - stop running ctn
- `docker rm <ctn_name>` - remove ctn

## Create own docker file

It is better to define the env variables externally in a docker-compose file.
They can be easily modified

| Image env blueprint                     | Dockerfile                                                              | comment                                                                                                                                                                         |
| --------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| install node                            | `FROM node`                                                             | start basing it on another image                                                                                                                                                |
| set env variables                       | <code> ENV MONGO_DB_USERNAME=admin \ MONGO_DB_PASSWORD=password </code> | It is better to define the env variables externally in a docker-compose file. They can be easily modified                                                                       |
| create/home/app folder                  | `RUN mkdir -p home/app`                                                 | Using **Run**- canexecute any Linux command. The directory created inside a ctn, **NOT** on laptop or host!                                                                     |
| copy current folders/ files to home/app | `COPY . /home/app`                                                      | **COPY** commnads are execute on the **HOST**machine:exclamation: **.**: source **/home/app**: target, You can copy files in the host to the inside of the ctn image(/home/app) |
| star the app with: "node server.js      | `CMD ["node","server.js"]`                                              | Execute entry point Linux commands. This can be done becuase `Node` is pre-installed because of base image                                                                      |

### RUN vs CMD

- `CMD` = entry point command. Can have only ONCE
- `RUN` = can have multiple times in dockerfile

**Dockerfile**

- **NOTE** **:** Every base image is based on another Dockerfile
  e.g.: Node:20-alpine3.18 is buit on [its owned Dockerfile](https://github.com/nodejs/docker-node/blob/9ee59bf646e8be3ff6ae849e8119312f198be55c/21/alpine3.18/Dockerfile).

**Image layers**
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

**Create Docker image**<br>
`docker build -t <image_name:tag or version> <location>`

e.g.: `docker build -t first-docker-app:1.0 .`

- command to be executed in **project** directory
- `-t` : name of the image
- `.`: in current directory

**Rebuilding a docker image**
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
CMD ["node", "app/server.js"]
```

2. First, remove the ctn before image. Otherwise,

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker rmi e13d81857488
Error response from daemon: conflict: unable to delete e13d81857488 (must be forced) - image is being used by stopped container c4a59b347ccb
```

3. Remove ctn
   `docker rm <ctn_no>`

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
   `docker rmi <img_#>`

```bash

pjlinux@DESKTOP-OTE9RM3:~$ docker rmi e13d81857488
Untagged: first-docker-app:1.0
Deleted: sha256:e13d81857488f19b02f5221e39eecac7cbfaaec37295259d021ef3f0cdc34ecf
```

5. Rebuild the img

` docker build -t first-docker-app:1.0 .`

6. Confirm the creation of the image

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY          TAG             IMAGE ID       CREATED          SIZE
first-docker-app    1.0             410c09712a49   35 seconds ago   166MB
<
```

6. Run the docker ctn
   **NOTE**: it should be done in the project root directory

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker run first-docker-app:1.0
app listening on port 3000!

```

7. Confirm running the app

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS     NAMES
902adc1576a1   first-docker-app:1.0   "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes             adoring_haslett
```

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker logs 902adc1576a1
app listening on port 3000!
```

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker exec -it 902adc1576a1 /bin/bash
OCI runtime exec failed: exec failed: unable to start container process: exec: "/bin/bash": stat /bin/bash: no such file or directory: unknown
```

**NOTE**: Some times bash may not work, so use sh (one of them will work)

```sh
pjlinux@DESKTOP-OTE9RM3:~$ docker exec -it 902adc1576a1 /bin/sh
/home/app # ls
Dockerfile       README.md        app              docker-notes.md  mongo.yaml
/home/app # exit
pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS     NAMES
902adc1576a1   first-docker-app:1.0   "docker-entrypoint.s…"   12 minutes ago   Up 12 minutes             adoring_haslett
```

- check env file

```sh
pjlinux@DESKTOP-OTE9RM3:~$ docker exec -it 902adc1576a1 /bin/sh
/home/app # env
NODE_VERSION=20.10.0
HOSTNAME=902adc1576a1
YARN_VERSION=1.22.19
SHLVL=1
HOME=/root
MONGO_DB_USERNAME=admin
TERM=xterm
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MONGO_DB_PASSWORD=password
PWD=/home/app

```

```sh
/home/app # ls -a
.                ..               .git             Dockerfile       README.md        app              docker-notes.md  mongo.yaml
/home/app # ls /home/app
Dockerfile       README.md        app              docker-notes.md  mongo.yaml
/home/app # ls -1 /home/app
Dockerfile
README.md
app
docker-notes.md
mongo.yaml

```

8. Improve performance

- for better performance, ensure the dicrectories and files needed for running the app are in inside **"app"** directory.

```sh
/home/app # ls -1 /home/app/app
images
index.html
node_modules
package-lock.json
package.json
server.js
/home/app #

```

# Private Docker Repository

## Create a repo

`AWS > Free tier > ECR > Get started > Repo name > Create Repo > Repo`

**NOTE**:

- for each image, need to have one Repo
- NO multiple images per Repo

## Athenticate - docker login

- a MUST : **login to private repo = docker login**
- During the process, need to install _aws cli_ > `sudo apt install awscli`

`docker login` > get it from aws

### Install aws cli

- Follow [the guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to intall awscli

### aws login

#### create a user in IAM in aws

- IAM > Users > Create user
- Give a meaningfull name: e.g.: <span style="color:red; font-weight:bold">first-docker-app-admin</span>
- Set per mission: **Attached policy directly**
- Review and create

**Note**:

- to avoid <span style="color:red; font-weight:bold;">non TTY device</span> error.
- Pls follow below,

### Create a IAM Policy

- Open the IAM > Policies > Create Policy > Create Policy with JSON
- paste below in the policy doc

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["ecr:GetAuthorizationToken"],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

- Name the policy: **ECR-GetAuthorizationTokenPolicy** (give a meaningful name)
  > Create policy

### Attach the Policy to the User

IAM console > the user > **"Permissions"** tab > **Add Permissions** > **Attach existing policies directly** > select the **ECR-GetAuthorizationTokenPolicy** > **Attach Policy**

### Create access key

IAM > users > the user > Create Access key > Command Line Interface (CLI) > create

### Loging to aws cli

```aws
pjlinux@DESKTOP-OTE9RM3:~$ aws configure
AWS Access Key ID [****************TP4J]: AKIAVJOCV3RFZALBORFG
AWS Secret Access Key [****************BRoE]: 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
Default region name [eu-north-1]:
Default output format [None]:
pjlinux@DESKTOP-OTE9RM3:~$ aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 363869887563.dkr.ecr.eu-north-1.amazonaws.com
Login Succeeded
```

### Image Naming in docker registries

`registryDomain/imageName:tag`

e.g.:

1. Docker hub

- we pull `docker pull mongo:4.2`
- but actually it processes `docker pull docker.io/library/mongo:4.2`

2. AWS ECR

- `docker pull 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:latest`

3. this project

### Push the image to aws

1. Rename the image

- copy the commnad from aws **push commands first-docker-app**<br>
  `docker tag first-docker-app:latest 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:latest`
- `docker tag` = **rename the image**<br>
  `docker tag first-docker-app:1.0 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.0`
- the image is renamed to `363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.0`

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY          TAG     IMAGE ID       CREATED         SIZE
first-docker-app    1.0     410c09712a49   15 hours ago    166MB
```

- **Renaming**

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker tag first-docker-app:1.0 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.0

```

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY                                                      TAG IMAGE ID        CREATED         SIZE
363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app  1.0 410c09712a49    15 hours ago    166MB
first-docker-app                                                1.0 410c09712a49    15 hours ago    166MB
```

🛑 Push unsuccessfull due to unavailablity of the ECR privete service

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker push 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.0
The push refers to repository [363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app]
9af61d1b2b26: Retrying in 1 second
473250ed6999: Retrying in 1 second
e6e17c0d72ff: Retrying in 1 second
177e8671cea0: Retrying in 1 second
0836ffd7c491: Retrying in 1 second
9fe9a137fd00: Waiting
EOF
```

### Edit Pilicies

__IAM >> Policies >> ECR-GetAuthorizationTokenPolicy >> Edit >> JSON__

```json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::363869887563:user/first-docker-app-admin"
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  ]
}

```


```bash
pjlinux@DESKTOP-OTE9RM3:~$ aws sts get-caller-identity
{
    "UserId": "AIDAXXXXXXXXXXXXXXYV",
    "Account": "xxxxxxxx",
    "Arn": "arn:aws:iam::xxxxxxxx:user/first-docker-app-admin"
}

```
`sts` : Security Token Service <br>
`get-caller-identity` : retrieve information about the AWS identity

__>> Edit name >> Save__

```bash
pjlinux@DESKTOP-OTE9RM3:~$ aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/x0q3i8z8
WARNING! Your password will be stored unencrypted in /home/pjlinux/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

___Rename the image___

```bash
~$ docker tag first-docker-app:1.0 public.ecr.aws/x0q3i8z8/first-docker-app:1.0
```

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY                                                    TAG   IMAGE ID       CREATED         SIZE
363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app 1.0  410c09712a49   17 hours ago    166MB
first-docker-app                                               1.0  410c09712a49   17 hours ago    166MB
```

### push the repo

`docker push public.ecr.aws/x0q3i8z8/first-docker-app:1.0`

🏆 it works!

```bash
The push refers to repository [public.ecr.aws/x0q3i8z8/first-docker-app]
9af61d1b2b26: Pushed
473250ed6999: Pushed
e6e17c0d72ff: Pushed
177e8671cea0: Pushed
0836ffd7c491: Pushed
9fe9a137fd00: Pushed
1.0: digest: sha256:ba63e527087433e9bdf5ab788dd530ffb084183e8cd41462e15a3d4ec3c087ce size: 1577
```

- Ref the image in the doc for further confirmation and details, url, sha, etc...

### Configure Docker Credential Helper:

1. **Install the docker-credential-helper (if not installed):**

   ```bash
   sudo apt-get install docker-credential-helper
   ```

2. **Configure Docker to use the credential helper:**

   Add the following lines to your Docker daemon configuration file. Create the file if it doesn't exist.

   ```bash
   echo '{"credsStore": "desktop"}' | sudo tee /etc/docker/daemon.json
   ```

   Replace "desktop" with the credential helper you want to use. Common credential helpers include "secretservice" for Linux systems.

3. **Restart the Docker daemon:**

   ```bash
   sudo systemctl restart docker
   ```

### Verify Docker Credential Helper:

Run the `docker login` command again, and the warning about storing the password unencrypted should no longer appear:

```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/x0q3i8z8
```

## Adding versions / modified containers to aws

- Do the modification to the app
- Build the docker image

`docker build -t first-docker-app:1.1 .`

`pjlinux@DESKTOP-OTE9RM3:~/first-docker-app$ docker build -t first-docker-app:1.1 .`

:exclamation: uer the ___corect___ directory
<br>
🏆 it worked!

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker images
REPOSITORY                                                        TAG   IMAGE ID       CREATED        SIZE
first-docker-app                                                  1.1   d6b7a201ee59   15 seconds ago 166MB
363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app    1.0   410c09712a49   18 hours ago   166MB
first-docker-app                                                  1.0   410c09712a49   18 hours ago   166MB
```

- Again push the image to ECR
`docker push <image_name>:<tag>`

```bash
pjlinux@DESKTOP-OTE9RM3:~$ docker push 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.1
The push refers to repository [363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app]
498575780c3c: Pushed
473250ed6999: Layer already exists
e6e17c0d72ff: Layer already exists
177e8671cea0: Layer already exists
0836ffd7c491: Layer already exists
9fe9a137fd00: Layer already exists
1.1: digest: sha256:20b113xxxxxxxxxxxxxxxxxxxxxxxxd5954e70ab2a3be7 size: 1577
pjlinux@DESKTOP-OTE9RM3:~$

```

- Retrieve an authentication token and authenticate the Docker client to the registry

`aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/x0q3i8z8`

`Error saving credentials: error storing credentials - err: exit status 1, out: `error storing credentials - err: exit status 1, out: `The stub received bad data.`

to address the above error need to remove **_Remove Docker Credentials_**

### Remove Docker Credentials

Remove any existing credentials stored by Docker<br>
`sudo rm ~/.docker/config.json`<br>
`sudo rm -rf ~/.docker/trust`

## Deploy our containerized app

- For the deployment,
__My app__ >> from private ECR <br>
__Mongodb and Mongo-express__ >> from docker hub
- Must login to private docker repository before pulling the image
- No need to loging to public docker hub

#### Private image
- from the ECR
- Need to maintain the sysntax `${docker-registry}/my-app:1.0`
- otherwise, docker will search in docker hub

`image: 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.1`

#### ports

```json
ports:
      3000:3000
```
#### environment:
- Config in docker-compose.yaml (mongo.yaml)


```json
environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
```
- Ther docker compose file would be used on the server to deploy all the apps/services

```json
version: '3'

services:
  my-app:
    image: 363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.1
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
### Process
1. Docker loging to simulate dev server

`aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 3xxxxxxxxxxx.dkr.ecr.eu-north-1.amazonaws.com`

2. Create `docker-compose.yaml` file in this case `mongo.yaml` file in current dirctory
- use `nano mongo.yaml`
- copy paste the content

3 start all __three__ containers using docker-compose
`docker-compose -f <docker-compose file>`

```bash
docker-compose -f mongo.yaml up
[+] Running 4/4
 ✔ Network pjlinux_default            Created                                                                                                   0.8s
 ✔ Container pjlinux-my-app-1         Created                                                                                                   1.2s
 ✔ Container pjlinux-mongo-express-1  Created                                                                                                   1.2s
 ✔ Container pjlinux-mongodb-1        Created                                                                                                   1.2s
Attaching to mongo-express-1, mongodb-1, my-app-1
mongodb-1        | about to fork child process, waiting until server is ready for connections.
```

4. you can work in the app local server

5. Recreate the database and collection 

6. change the __connect nodejs with mongodb__

```json
${process.env.MONGO_HOST}:${process.env.MONGO_PORT} to @$mongodb
```
because of mongodb is a service specified in docker-compose file where all the details have been alreay included in the config, 

```yaml
    mongodb:
    image: mongo
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password


```


```json
let mongoUrlDocker = `mongodb:${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@${process.env.MONGO_HOST}:${process.env.MONGO_PORT}`;
```
__to__

```json
let mongoUrlDocker = `mongodb:${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@$mongodb`;
```

## Docker Volumes - Persist data in Docker

1. When >> for data persistance when you have,
            - **Data Persistence:**
        - Ensure data survives container recreation.

        - **Share Data Between Containers:**
        - Facilitate communication and data exchange.

        - **Database Storage:**
        - Store database files securely.

        - **Efficient Backups:**
        - Simplify data backup and restoration.

        - **Cross-Platform Consistency:**
        - Maintain data integrity across platforms.

        - **Optimize Performance:**
        - Improve I/O performance for containers.

2. What
Folder in the pysical host file systm in __HOST__ is ___mounted___ into the vertual file system in __Dockers__


3. 3 types
 
- Host Volume
    - to create volume, uses `docker run -v` command

        `docker run -v /host/path:/container/path` <br>
        `v` - volume
    
    - you can decide where on the hose file system the ref is made

- Anonymoudr volume
    - crete colume just referencing the container directory
    - the directory on the host to be mounted is taken care by ___Dockers___

    `docker run -v /path/in/container my_image`

- Named volume
    - you can referene the volume by name
    - One shuould be used in the production 
    - more freaquantly
    
    `docker run -v host-volue-name:/path/in/container my-image`

    - can mount named-volumes for different containers still with the __different folder path__
    - list all of them down at the bottom of docker-compose file with the sarvice level
    - :exclamation: - we too use <span style="color: red; font-weight: bold;">Named volume</span>

    - Find the path
        - each database has it own default path on Linux,
            - [Mongodb - /data/db](https://www.mongodb.com/docs/manual/tutorial/manage-mongodb-processes/#:~:text=By%20default%2C%20MongoDB%20listens%20for,in%20C%3A%5Cdata%5Cdb%20.)
            - [Postgress - /var/lib/pgsql/MAJOR_RELEASE/data/](https://www.postgresql.org/docs/current/storage-file-layout.html)
            - [Sql - /var/lib/mysql](https://www.baeldung.com/linux/mysql-database-files-location#:~:text=Default%20Location,conf.)
    
    - Conform in dev server

    `docker ps`

```bash
        pjlinux@DESKTOP-OTE9RM3:~$ docker ps
CONTAINER ID   IMAGE                                                                COMMAND                  CREATED              STATUS              PORTS                      NAMES
a519fcc9e8b2   363869887563.dkr.ecr.eu-north-1.amazonaws.com/first-docker-app:1.1   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3000->3000/tcp     pjlinux-my-app-1
e3a5a3db26bf   mongo                                                                "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:27017->27017/tcp   pjlinux-mongodb-1
ad2181c17bce   mongo-express                                                        "/sbin/tini -- /dock…"   About a minute ago   Up About a minute   0.0.0.0:8080->8081/tcp     pjlinux-mongo-express-1
902adc1576a1   410c09712a49                                                         "docker-entrypoint.s…"   31 hours ago         Up 31 hours                                    adoring_haslett
```
`docker exec -it e3a5a3db26bf sh`

```bash
    pjlinux@DESKTOP-OTE9RM3:~$ docker exec -it e3a5a3db26bf sh
# ls
bin  boot  data  dev  docker-entrypoint-initdb.d  etc  home  js-yaml.js  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
# ls /data
configdb  db
# ls /data/db
WiredTiger         _mdb_catalog.wt                       diagnostic.data                  index-8--7533634255959008042.wt  storage.bson
WiredTiger.lock    collection-0--7533634255959008042.wt  index-1--7533634255959008042.wt  index-9--7533634255959008042.wt
WiredTiger.turtle  collection-2--7533634255959008042.wt  index-3--7533634255959008042.wt  journal
WiredTiger.wt      collection-4--7533634255959008042.wt  index-5--7533634255959008042.wt  mongod.lock
WiredTigerHS.wt    collection-7--7533634255959008042.wt  index-6--7533634255959008042.wt  sizeStorer.wt

```
<br>
    -  Modify docker-compose (mongo.yaml)
        - Add volume at service level
            ```yaml
            volumes:
                - mongo-data:/data/db
            ```

<br>

__:exclamation: All the date in `mongo-data` now replcated in `/data/db` at the start :exclamation:__

<br>

        - Add volume at bottom of the file

<br>

```yaml
    volumes:
      mongo-data:
        driver: local
```


4. MongoDB dependancy - fix the timing of the start up
- To help the mongo-express to find mongodb, 
- `mongo-express` __MUST__ wait till `MongoDB` __full started__
- Solution,
    - Add a delay
    ```yaml
    depends_on:
      - mongodb  # Wait for MongoDB to be ready
    ```

    - implement wait script
    ```yaml
    command: ["./wait-for-mongo.sh", "mongodb:27017", "--", "npm", "start"]
    ```

4. config in docker-compose file in the docker
- stop dev server - `crt+c`
- Shutdown Docker containers  - `docker-compose -f mongo.yaml down`
- modify the docker-compose file
- Restart the docker containers - `docker-compose -f mongo.yaml up`
- check `localhost:8080`, now no database loss



:trophy: it works:exclamation:

