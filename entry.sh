#!/bin/sh

export SONATYPE_DIR=/opt/sonatype
export NEXUS_HOME=/opt/sonatype/nexus
export NEXUS_DATA=/nexus-data
export NEXUS_CONTEXT=
export SONATYPE_WORK=/opt/sonatype/sonatype-work

export JAVA_HOME=/usr/local/openjdk-8
export INSTALL4J_HOME="${JAVA_HOME}"
export INSTALL4J_ADD_VM_PARAMS="-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=/nexus-data/javaprefs"

exec /opt/sonatype/nexus/bin/nexus run

