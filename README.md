# ZabbixSLAReport
The following script permits get day by day SLA result for specific service IDs. You can get the SLA for a specific month and ID or just, put the ID and get the data from the previous month.

# Requierements

 - Bash
 - jq

# Usage
For the first use, you have to set ZABBIX_IP variable and API_PASSWORD variable to execute it correctly. Both variables do not santize string.

Actually you can use a couple of parameters that will give you some options. For further information please check help command.

Ex:
```
user@host$ Report.sh -id 10

100
100
100
100
99.837962962963
100
100
100
100
100
100
100
100
100
99.930555555556
100
100
100
99.907407407407
100
100
100
100
100
100
99.91087962963
100
100
100
100
100
```

# To Do
Better documentation
