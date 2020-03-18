#!/usr/bin/env bash


BASEDIR=$(dirname "$0")

# shellcheck disable=SC1090
source "${BASEDIR}/runstats.profile"

AUTHSTRING="Authorization: Splunk ${TOKEN}"
SCRIPTFILE="/usr/local/lib/showanyconnectstats.txt"

FIRST=1
FINALSTATS=""

# shellcheck disable=SC2013
for router in $(cat "${RANCIDFOLDER}/routers.all"); do
	routername=$(echo -n "${router}" | awk -F':' '{print $1}')

	stat=$(echo "${routername}" | xargs -I{} sh -c "clogin -x ${SCRIPTFILE} {} | grep -c Username")

	stattoadd=$(echo -n "\"${routername}\":\"${stat}\"")
	if [ "${FIRST}" -eq 1 ]; then
		FIRST=0
		FINALSTATS="${stattoadd}"
	else
		FINALSTATS="${FINALSTATS},${stattoadd}"
	fi
done

EVENTDATA="{\"sourcetype\": \"_json\", \"event\": {${FINALSTATS}}}"
curl -s "${HECURL}" -H "${AUTHSTRING}" -d "${EVENTDATA}"