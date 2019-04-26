#!/bin/bash

API_PASS=
ZABBIX_IP=

#Get first day of past month
l_first_date=$(date -d "`date +%Y%m01` -1 month" +%s)
#Get last day of past month
l_last_date=$(date -d "`date +%Y%m01` -1 day" +%s)

getToken() {
	token=$(curl -s -i -X POST -H 'Content-Type:application/json' -d'{"jsonrpc": "2.0","method":"user.login","params":{"user":"grafana","password":"'$API_PASS'"},"auth": null,"id":0}' http://'$ZABBIX_IP'/zabbix/api_jsonrpc.php | tail -1 | cut -f2 -d"," | cut -f2 -d":" | tr -d '"')
}

generateJson() {
	serviceid=$1
	echo "{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"service.getsla\",
	    \"params\": {
	        \"serviceids\": \"$serviceid\",
	        \"intervals\": [" > get_sla.json
	dia_sla=$l_first_date
	while [ $dia_sla -le $l_last_date ]
	do
		if [ $dia_sla -lt $l_last_date ];then
			next_day=$(($dia_sla+86400))
			echo "   { 
			\"from\": $dia_sla,
			\"to\": $next_day 
			}," >> get_sla.json
		else
			next_day=$(($dia_sla+86400))
	                echo "   { 
	                \"from\": $dia_sla,
	                \"to\": $next_day 
	                }" >> get_sla.json
		fi
		dia_sla=$(($dia_sla+86400))
	done
	echo "]
	    }," >> get_sla.json
	echo "\"auth\": \"$token\",
		\"id\":1
		}" >> get_sla.json
}

apiCall() {
	## LLAMADA A LA API
	curl -s -X POST -H 'Content-Type:application/json' -d@get_sla.json http://$ZABBIX_IP/zabbix/api_jsonrpc.php | jq '.result | .[].sla | .[].sla '
}


main() {
	
	case $1 in
        	alta)
	          serviceid=3
	          ;;
	        media)
        	  serviceid=7
	          ;;
	        resumen)
        	  serviceid=12
	          ;;
	        *)
        	  echo "ERROR - Opciones válidas: alta, media o resumen"
	          ;;
	esac
	getToken
	generateJson $serviceid
	apiCall
}
main $@
