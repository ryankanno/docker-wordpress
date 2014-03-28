docker-wordpress
================

HERE BE DRAGONS
===============

Just a tiny Dockerfile for all the WP blogs I still host for peoples.  Lots of
dragons here, but less everyday.

  * wordpress (mysql / php)
  * nginx
  * open-ssh

Requires that an authorized_keys file is present in the DockerFile dir.

Note: Exposed ssh into the container to debug / troubleshoot.

Build
=====

`docker build -t wordpress .`

Run
===

`docker run -n -p 80:80 -p 2212:22 -d wordpress`

TODO
====

Move more of the variability into the configure script
