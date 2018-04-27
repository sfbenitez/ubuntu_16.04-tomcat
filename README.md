* [travis-ci.org (timestamped-commit tag):](https://hub.docker.com/r/fiwoo/ubuntu_16.04-tomcat/) [![Build Status](https://travis-ci.org/fiwoo-platform/ubuntu_16.04-tomcat.svg?branch=master)](https://travis-ci.org/fiwoo-platform/ubuntu_16.04-tomcat)

# ToC (Table of Contents)

   * [Rationale. YATDC?](#rationale-yaddc)
      * [So, what's this about?](#so-whats-this-about)
   * [Requirements](#requirements)
   * [Start a tomcat development](#start-a-drupal-development)
      * [Setup considerations](#setup-considerations)
   * [Build your own custom docker image](#build-your-own-custom-docker-image)
   * [Destroy docker enviroment](#destroy-docker-enviroment)
   * [FAQ](#faq)
   * [Contributing](#contributing)
   * [Licence and Authors](#licence-and-authors)
   * [TODO: sort braindumped notes](#todo-sort-braindumped-notes)

# Rationale. YATDC?

You will wonder, yet another tomcat docker container?

And our answer is 'yes', a container for developers. We craft it with love listening to our java developers suggestions; since they are the ones who use it everyday.

This container is not intended for production, but it could.

## So, what's this about?

This a tomcat docker container based on the latest Ubuntu LTS release (Long Time Support, ubuntu-16.04) that pretends to be developer friendly and makes easy the task of starting a local, containerized development.

* Cloning/Forking this repository
* Either:
  * Copying a java '.war' into '${DATA_DIR}/docker-containers-volumes/opt/apache-tomcat/webapps' inside project's dir
* Or:
  * Use the entrypoint function build-war-file() in /assets/bin
* Start the enviroment

# Requirements

* Install latest [docker-engine](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install)

# Start a java development

* Fork and clone this project:
```
git clone https://github.com/Emergya/ubuntu_16.04-tomcat.git my-tomcat
cd my-tomcat
```
* Setup your enviroment variables accordingly:
```
export DOCKER_IMAGE="emergya/ubuntu_16.04-tomcat:latest"
export TOMCAT_VERSION=8.5.30

export DEVELOPER_USER=$(basename $HOME)
export PROJECT_NAME="my-tomcat"
export ENVIRONMENT="dev"
export ENV_VHOST="$ENVIRONMENT-$PROJECT_NAME.example.com"

export PROJECT_DIR="$PWD"           # dir where the fork is placed
export DATA_DIR="$PROJECT_DIR/data"  # dir where docker volumes are stored
export SSH_CREDENTIALS_DIR=~/.ssh   # this one is used to share you ssh credentials with the containerized git

sed -i "s|$ENVIRONMENT-_PROJECT_NAME_.emergyalabs.com|$ENV_VHOST|g" $ENVIRONMENT-compose.yml # renames compose service name to use your microservice FQDN

```

* Run the environment:
```
docker-compose -f $ENVIRONMENT-compose.yml up -d
```
### Setup considerations

* If you want a database to be deployed as initial database, you can place it in '$PROJECT_DIR/data/initial.sql'.
Note also that, because the dump is programatically imported by container's entrypoint and it does have a predefined $MYSQL_DBNAME, the dump must include the 'CREATE DATABASE' and 'USE $MYSQL_DBNAME' statements at the begining.
While running the environment, you will also need to set this variable in order to render 'settings.php' correctly:
```
export MYSQL_DBNAME="your-db-name"
```

# Build your own custom docker image

* Modify 'Dockerfile' or include any asset on the 'assets' directory (they will be included in container's root filesystem following the same directories hierarchy)
* Build the image accordingly:
```
### Define env variables
export TOMCAT_VERSION=8.5.30
export MAVEN_VERSION=3.3.9

docker build --build-arg TOMCAT_VERSION=$TOMCAT_VERSION --build-arg MAVEN_VERSION=$MAVEN_VERSION -t emergya/ubuntu_16.04-tomcat:latest .
```

# Destroy docker enviroment

```
export ENVIRONMENT="dev"
cd $PROJECT_DIR
docker-compose -f $ENVIRONMENT-compose.yml down -v
sudo rm -rf data
```

# FAQ

# Contributing

1.  Fork the repository on Github
2.  Create a named feature branch (like `add_component_x`)
3.  Write your changes
4.  Submit a Pull Request using Github

# Licence and Authors

Copyright © 2017 Emergya < http://www.emergya.com >

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    The license text is available at https://www.gnu.org/licenses/agpl-3.0.html

Authors:
* [Andrés Muñoz Vera](https://github.com/pellejador) (<amunoz@emergya.com>)
* [Antonio Rodriguez Robledo](https://github.com/yocreoquesi) (<arodriguez@emergya.com>)
* [Alejandro Romo Astorga](https://github.com/aromo) (<aromo@emergya.com>)
* [Diego Martín Sanchez](https://github.com/dmsgago) (<dmsanchez@emergya.com>)
* [Héctor Fiel Martín](https://github.com/hfiel) (<hfiel@emergya.com>)
* [Roberto C. Morano](https://github.com/rcmorano) (<rcmorano@emergya.com>)

# TODO: sort braindumped notes

* Note you are using a monolithic container that encapsulates everything, for running it on production, you might start thinking about a decoupled mysql server that is there just to be developer friendly
* In production we should use the container produced by a CI pipeline image and use the source code included inside of that image; you can change the environment divergence in the entrypoint's defined function _set-environment-divergences_
* We perform many of these task as automated project-tasks by using baids
