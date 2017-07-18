# Overview

This repository contains a Dockerfile and some scripts which demonstrate a way in which you might run [IBM Integration Bus](http://www-03.ibm.com/software/products/en/ibm-integration-bus) in a [Docker](https://www.docker.com/whatisdocker/) container.

IBM would [welcome feedback](#issues-and-contributions) on what is offered here.

# Building the image

The image can be built using standard [Docker commands](https://docs.docker.com/userguide/dockerimages/) against the supplied Dockerfile.  For example:

~~~
cd 10.0.0.9
docker build -t iibv10image .
~~~

This will create an image called `iibv10image` occupying approximately 1.15GB of space (including the size of the underlying Ubuntu base image) in your local Docker registry:

~~~
REPOSITORY     TAG       IMAGE ID        CREATED          SIZE
iibv10image    latest    b8403ecfcd0d    2 seconds ago    1.15GB
ubuntu         14.04     132b7427a3b4    3 weeks ago      188MB
~~~

# What the image contains

The built image contains a full installation of [IBM Integration Bus for Developers Edition V10.0](https://ibm.biz/iibdevedn).  It does not contain an installation of IBM MQ so some functionality may not be available, or may be changed - see this [topic](http://www-01.ibm.com/support/knowledgecenter/SSMKHH_10.0.0/com.ibm.etools.mft.doc/bb28660_.htm) for more information

# Running a container

After building a Docker image from the supplied files, you can [run a container](https://docs.docker.com/userguide/usingdocker/) which will create and start an Integration Node to which you can [deploy](http://www-01.ibm.com/support/knowledgecenter/SSMKHH_10.0.0/com.ibm.etools.mft.doc/af03890_.htm) integration solutions.

In order to run a container from this image, it is necessary to accept the terms of the IBM Integration Bus for Developers license.  This is achieved by specifying the environment variable `LICENSE` equal to `accept` when running the image.  You can also view the license terms by setting this variable to `view`. Failure to set the variable will result in the termination of the container with a usage statement.  You can view the license in a different language by also setting the `LANG` environment variable.

In addition to accepting the license, you can optionally specify an Integration Node name using the `NODENAME` environment variable.

The last important point of configuration when running a container from this image, is port mapping.  The Dockerfile exposes ports `4414` and `7800` by default, for Integration Node administration and Integration Server HTTP traffic respectively.  This means you can run with the `-P` flag to auto map these ports to ports on your host.  Alternatively you can use `-p` to expose and map any ports of your choice.

For example:

~~~
docker run --name myNode -e LICENSE=accept -e NODENAME=MYNODE -P iibv10image
~~~

This will run a container that creates and starts an Integration Node called `MYNODE` and exposes ports `4414` and `7800` on random ports on the host machine.  At this point you can use:
~~~
docker port <container name>
~~~

to see which ports have been mapped then connect to the Node's web user interface as normal (see [verification](# Verifying your container is running correctly) section below).

### Running administration commands

You can run any of the Integration Bus
 commands using one of two methods:

##### Directly in the container

Attach a bash session to your container and execute your commands as you would normally:

~~~
docker exec -it <container name> /bin/bash
~~~

At this point you will be in a shell inside the container and can source `mqsiprofile` and run your commands.

##### Using Docker exec

Use Docker exec to run a non-interactive Bash session that runs any of the Integration Bus commands.  For example:

~~~
docker exec <container name> /bin/bash -c mqsilist
~~~

### Accessing logs

This image also configures syslog, so when you run a container, your node will be outputting messages to /var/log/syslog inside the container.  You can access this by attaching a bash session as described above or by using docker exec.  For example:

~~~
docker exec <container id> tail -f /var/log/syslog
~~~

# Verifying your container is running correctly

Whether you are using the image as provided or if you have customised it, here are a few basic steps that will give you confidence your image has been created properly:

1. Run a container, making sure to expose port 4414 to the host - the container should start without error
2. Run mqsilist to show the status of your node as described above - your node should be listed as running
3. Access syslog as descried above - there should be no errors
4. Connect a browser to your host on the port you exposed in step 1 - the Integration Bus web user interface should be displayed.

At this point, your container is running and you can [deploy](http://www-01.ibm.com/support/knowledgecenter/SSMKHH_10.0.0/com.ibm.etools.mft.doc/af03890_.htm) integration solutions to it using any of the supported methods.



# Issues and contributions

For issues relating specifically to this Docker image, please use the [GitHub issue tracker](https://github.com/ot4i/iib-docker/issues). For more general issues relating to IBM Integration Bus or to discuss the Docker technical preview, please use the [Integration Community](https://developer.ibm.com/integration/). If you do submit a Pull Request related to this Docker image, please indicate in the Pull Request that you accept and agree to be bound by the terms of the [IBM Contributor License Agreement](CLA.md).

# License

The Dockerfile and associated scripts are licensed under the [Eclipse Public License 1.0](./LICENSE). IBM Integration Bus for Developers is licensed under the IBM International License Agreement for Non-Warranted Programs. This license may be viewed from the image using the `LICENSE=view` environment variable as described above. Note that this license does not permit further distribution.
