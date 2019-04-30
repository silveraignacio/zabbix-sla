# ZabbixSLAReport
The following script permits get day by day SLA result for specific service IDs. It will get all the data of the previous month. If you execute it 3rd May, it will get all the data from 1st April to 30th April day by day.

# Usage
The usage of the scrip is still limited. It has predefined Services based on my own environment but on following releases it will have more features.

For the first use, you have to set ZABBIX_IP variable and API_PASSWORD variable to execute it correctly. Both variables do not santize string.

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
