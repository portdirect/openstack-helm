#!/bin/bash
set -ex
OPENSTACK_VERSION="stable/queens"
IMAGE_TAG="${OPENSTACK_VERSION#*/}"

sudo docker run -d \
  --name docker-in-docker \
  --privileged=true \
  --net=host \
  -v /var/lib/docker \
  -v ${HOME}/.docker/config.json:/root/.docker/config.json:ro\
  docker.io/docker:17.07.0-dind \
  dockerd \
    --pidfile=/var/run/docker.pid \
    --host=unix:///var/run/docker.sock \
    --storage-driver=overlay2
sudo docker exec docker-in-docker apk update
sudo docker exec docker-in-docker apk add git

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --network host \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT=requirements \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --tag docker.io/openstackhelm/requirements:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/requirements:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=keystone \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="apache ldap" \
    --build-arg PIP_PACKAGES="pycrypto python-openstackclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/keystone:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/keystone:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=heat \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="apache" \
    --build-arg PIP_PACKAGES="python-senlinclient" \
    --build-arg DIST_PACKAGES="curl" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/heat:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/heat:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=barbican \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/barbican:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/barbican:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=glance \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="glance ceph" \
    --build-arg PIP_PACKAGES="pycrypto python-swiftclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/glance:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/glance:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=cinder \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="cinder lvm ceph qemu" \
    --build-arg PIP_PACKAGES="pycrypto python-swiftclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/cinder:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/cinder:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=neutron \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="neutron linuxbridge openvswitch" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/neutron:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/neutron:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=neutron \
    --build-arg FROM=docker.io/ubuntu:18.04 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="neutron linuxbridge openvswitch" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg DIST_PACKAGES="ethtool lshw" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/neutron:${IMAGE_TAG}-sriov-1804
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/neutron:${IMAGE_TAG}-sriov-1804

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=nova \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="nova ceph linuxbridge openvswitch configdrive qemu apache" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/nova:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/nova:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=horizon \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="horizon apache" \
    --build-arg PIP_PACKAGES="django-nose heat-dashboard git+https://github.com/openstack/senlin-dashboard.git@stable/queens git+https://github.com/openstack/ironic-ui.git@stable/queens" \
    --build-arg DIST_PACKAGES="gettext libgettextpo-dev" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/horizon:${IMAGE_TAG}

tee > /tmp/manage-heat-dashboard.py <<EOF
#!/usr/bin/env python
import os
import sys

from django.core.management import execute_from_command_line

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE",
                          "heat_dashboard.test.settings")
    execute_from_command_line(sys.argv)
EOF
HORIZON_HEAT_MANAGE_PY=$(base64 -w0 /tmp/manage-heat-dashboard.py)
tee > /tmp/Dockerfile.horizon-clients <<EOF
FROM docker.io/openstackhelm/horizon:${IMAGE_TAG}
RUN set -ex ;\
  SITE_PACKAGES=\$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") ;\
  ln -vs \${SITE_PACKAGES}/heat_dashboard/enabled/_[1-9]*.py \${SITE_PACKAGES}/openstack_dashboard/local/enabled ;\
  cd \${SITE_PACKAGES}/heat_dashboard ;\
  echo ${HORIZON_HEAT_MANAGE_PY} | base64 -d > /tmp/manage-heat-dashboard.py ;\
  python /tmp/manage-heat-dashboard.py compilemessages ;\
  ln -vs \${SITE_PACKAGES}/senlin_dashboard/enabled/_50_senlin.py \${SITE_PACKAGES}/openstack_dashboard/local/enabled/ ;\
  ln -vs \${SITE_PACKAGES}/ironic_ui/enabled/_2200_ironic.py \${SITE_PACKAGES}/openstack_dashboard/local/enabled/
EOF
HORIZON_HEAT_DOCKERFILE=$(base64 -w0 /tmp/Dockerfile.horizon-clients)
sudo docker exec docker-in-docker sh -c "echo $HORIZON_HEAT_DOCKERFILE | base64 -d > /tmp/Dockerfile.horizon-clients"
sudo docker exec docker-in-docker docker build --file /tmp/Dockerfile.horizon-clients /tmp --tag docker.io/openstackhelm/horizon:${IMAGE_TAG}-clients
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/horizon:${IMAGE_TAG}-clients

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=senlin \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="senlin" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/senlin:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/senlin:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=congress \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="congress" \
    --build-arg PIP_PACKAGES="pycrypto python-congressclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/congress:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/congress:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=magnum \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="magnum" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/magnum:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/magnum:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=ironic \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="ironic ipxe ipmi qemu tftp" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg DIST_PACKAGES="iproute2" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/ironic:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/ironic:${IMAGE_TAG}
