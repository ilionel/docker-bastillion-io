#!/bin/ash
# shellcheck shell=dash

savejceks() {
  # copy JCEKS to persistent folder
  if [ -f /opt/bastillion/jetty/bastillion/WEB-INF/classes/bastillion.jceks ]; then
    echo "[startBastillion.sh INFO] copy JCEKS file to a save place"
    cp /opt/bastillion/jetty/bastillion/WEB-INF/classes/bastillion.jceks \
       /opt/bastillion/jetty/bastillion/WEB-INF/classes/keydb/bastillion.jceks
  fi
}

trap savejceks EXIT

# restore bastillion.jceks from persistent storage
if [ -f /opt/bastillion/jetty/bastillion/WEB-INF/classes/keydb/bastillion.jceks ]; then
  echo "[startBastillion.sh INFO] restoring JCEKS file from persistent storage"
  cp /opt/bastillion/jetty/bastillion/WEB-INF/classes/keydb/bastillion.jceks \
     /opt/bastillion/jetty/bastillion/WEB-INF/classes/bastillion.jceks
fi

# change to jetty dir and start jetty
cd jetty || exit 1
java -Xms1024m -Xmx1024m -jar start.jar