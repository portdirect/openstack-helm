Kubernetes-Entrypoint Image Build
=================================

Builds an image with kubernetes-entrypoint for use with OpenStack-Helm.

Prerequisites
-------------

Must have golang 1.7.x installed in order to build the binary.

Instructions
------------

Build the Kubernetes-Entrypoint Image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A known good image is published to docker hub on a fairly regular basis, but if
you wish to build your own image, from the directory containing this README run:

.. code:: bash
    # Example configuration overrides, see Makefile for all available options:
    # export IMAGE_REPO=quay.io
    # export GIT_REPO=https://github.com/someuser/kubernetes-entrypoint.git
    # export GIT_REF=someref
    make
