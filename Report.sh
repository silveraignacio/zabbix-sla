#!/bin/bash

#Main Variables
API_PASS=
ZABBIX_IP=

# Help message.
help_message () { cat << EOF
[ ERROR ] - Missig arguments
Description:
  Simple script that permits get day by day SLA result for specific service IDs. It will get all the data of the previous month. If you execute it 3rd May, it will get all the data from 1st April to 30th April day by day..
  You have to set API_PASS and ZABBIX_IP variables to start using it. It has been tested on Zabbix 4.0.4
  Syntax:
	  ./$0 [-m month ] [-id serviceid ]
  Options:
	  -h/--help
	    Display this help message.
	  -m/--month <id>
	    Get SLA for desired month. It's necesseary to put the service id.
	  -id/--serviceid
	   Get SLA for particular ID (just admit one)
	  -s/--services
	    Get list of configured services
EOF
}

getToken() {
	token=$(curl -s -i -X POST -H 'Content-Type:application/json' -d'{"jsonrpc": "2.0","method":"user.login","params":{"user":"grafana","password":"'$API_PASS'"},"auth": null,"id":0}' http://"$ZABBIX_IP"/zabbix/api_jsonrpc.php | tail -1 | cut -f2 -d"," | cut -f2 -d":" | tr -d '"')
}

generateJson() {
	#Get first day of past month
	l_first_date=$(date -d "`date +%Y%m01` -1 month" +%s)
	#Get last day of past month
	l_last_date=$(date -d "`date +%Y%m01` -1 day" +%s)

	serviceid=$1
	
	if isDigit "$serviceid";then
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
	else
		echo "ERROR: ServiceID is not a numeric type."
		exit 1
	fi
}

getSla() {
	curl -s -X POST -H 'Content-Type:application/json' -d@get_sla.json http://$ZABBIX_IP/zabbix/api_jsonrpc.php | jq '.result | .[].sla | .[].sla '
}

getServices() {
	echo '{
    "jsonrpc": "2.0",
    "method": "service.get",
    "params": {
        "output": "extend",
        "selectDependencies": "extend"
    },
    "auth": "'$token'",
    "id": 1
}' > getServices.json
	echo "ID       NAME"
	curl -s -X POST -H 'Content-Type:application/json' -d@getServices.json http://"$ZABBIX_IP"/zabbix/api_jsonrpc.php | jq '.result | .[] | "\(.serviceid)       \(.name)"'
}

generateJsonMonth(){

	month=$1	

	if [[ $month == [0-1][0-9] ]];then
		#First day of input month
		l_first_date=$(date -d "`date +%Y"$month"01`" +%s)
		#Next month
		month=$(date -d "`date +%Y"$month"01` +1 month" +%m)
		#Last day of input month
		l_last_date=$(date -d "`date +%Y"$month"01` -1 day" +%s)

		serviceid=$2

		if isDigit "$serviceid";then
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
        else
        	echo "ERROR: ServiceID is not a numeric type."
        	exit 1
        fi
	else
		echo "ERROR: Wrong month input. It must have 2 numbers.(Ex: 04)"
		exit 2
	fi
}

isDigit() {

        case $1 in
                *[!0-9]*) return 1 ;;
        esac
}


main() {
		case $1 in
        		-id|--serviceid)
			  getToken
		          generateJson $2
			  getSla
		          ;;
			-m|--month)
		  	  month=$2
			  serviceid=$3
			  getToken
			  generateJsonMonth $month $serviceid
			  getSla
			  ;;
			-s|--services)
			  getToken
			  getServices
			  ;;
	        	*)
			  help_message
			  exit 1
		          ;;
		esac
}
main $@

